import json
import subprocess
import os
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
from pathlib import Path

class GitOpsWebhookHandler(BaseHTTPRequestHandler):
    
    ENVIRONMENTS = {
        'dev': {
            'branch': 'dev',
            'topology_path': '/opt/kafka_julie/git-repo/GITHUB_REPO',
            'kafka_brokers': 'kafka1:9092,kafka2:9092,kafka3:9092',
            'auto_deploy': True
        },
        'stage': {
            'branch': 'stage', 
            'topology_path': '/opt/kafka_julie/git-repo/GITHUB_REPO',
            'kafka_brokers': 'kafka1:9092,kafka2:9092,kafka3:9092',
            'auto_deploy': True
        },
        'prod': {
            'branch': 'prod',
            'topology_path': '/opt/kafka_julie/git-repo/GITHUB_REPO',
            'kafka_brokers': 'kafka1:9092,kafka2:9092,kafka3:9092',
            'auto_deploy': False
        }
    }
    
    def do_POST(self):
        if self.path == '/webhook':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                payload = json.loads(post_data.decode('utf-8'))
                branch_ref = payload.get('ref', '')
                
                # Extract branch name from refs/heads/branch-name
                if branch_ref.startswith('refs/heads/'):
                    branch_name = branch_ref.replace('refs/heads/', '')
                    
                    print(f"🔔 Webhook received for branch: {branch_name}")
                    print(f"📝 Commits: {len(payload.get('commits', []))}")
                    
                    # Log changed files for debugging
                    self.log_changed_files(payload)
                    
                    # Check if this branch maps to an environment
                    env_config = self.get_environment_config(branch_name)
                    
                    if env_config:
                        # Check if topology files were actually changed
                        if self.has_topology_changes(payload, env_config['topology_path']):
                            if env_config['auto_deploy']:
                                print(f"🚀 Auto-deploying to {branch_name} environment")
                                self.trigger_deployment(branch_name, env_config)
                            else:
                                print(f"⏸️  Manual approval required for {branch_name} environment")
                                self.log_pending_deployment(branch_name, payload)
                        else:
                            print(f"⏭️  No topology changes detected for {branch_name}")
                        
                        self.send_success_response(f"Processed {branch_name} branch")
                    else:
                        print(f"⏭️  Skipping: {branch_name} is not a monitored environment")
                        self.send_success_response("Branch not monitored")
                else:
                    print(f"⏭️  Skipping: Not a branch push - {branch_ref}")
                    self.send_success_response("Not a branch push")
                    
            except Exception as e:
                print(f"❌ Error processing webhook: {e}")
                self.send_error_response(str(e))
    
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'GitOps Multi-Environment Webhook is running!')
        
        elif self.path == '/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            status = {
                "environments": list(self.ENVIRONMENTS.keys()),
                "auto_deploy": [env for env, config in self.ENVIRONMENTS.items() if config['auto_deploy']],
                "manual_approval": [env for env, config in self.ENVIRONMENTS.items() if not config['auto_deploy']],
                "ngrok_url": "NGROK_URL_PLACEHOLDER"
            }
            self.wfile.write(json.dumps(status, indent=2).encode())
        
        elif self.path == '/deploy/prod':
            # Manual trigger for prod deployment
            env_config = self.ENVIRONMENTS['prod']
            print(f"🔄 Manual prod deployment triggered via API")
            self.trigger_deployment('prod', env_config)
            self.send_success_response("Prod deployment triggered manually")
    
    def log_changed_files(self, payload):
        """Log all changed files for debugging"""
        commits = payload.get('commits', [])
        all_changes = set()
        
        for commit in commits:
            added = commit.get('added', [])
            modified = commit.get('modified', [])
            removed = commit.get('removed', [])
            
            all_changes.update(added)
            all_changes.update(modified)
            all_changes.update(removed)
        
        if all_changes:
            print(f"📁 Changed files: {', '.join(sorted(all_changes))}")
        else:
            print(f"📁 No file changes detected")
    
    def has_topology_changes(self, payload, topology_base_path):
        """Check if any topology YAML files were changed in branch root"""
        commits = payload.get('commits', [])
        topology_changes = False
        
        for commit in commits:
            added = commit.get('added', [])
            modified = commit.get('modified', [])
            removed = commit.get('removed', [])
            
            all_changes = added + modified + removed
            
            for file_path in all_changes:
                if (file_path.endswith(('.yaml', '.yml')) and
                    '/' not in file_path and
                    not file_path.lower().startswith(('readme', 'config', '.git', 'combined-topology'))):
                    print(f"🎯 Topology change detected: {file_path}")
                    topology_changes = True
        
        return topology_changes
    
    def get_environment_config(self, branch_name):
        """Get environment configuration for a branch"""
        return self.ENVIRONMENTS.get(branch_name)
    
    def consolidate_topology_files(self, topology_path):
        """Combine all YAML files in directory into one for Julie"""
        try:
            yaml_files = []
            topology_dir = Path(topology_path)
            
            if not topology_dir.exists():
                print(f"⚠️  Topology directory does not exist: {topology_path}")
                return None
            
            # Find all YAML files
            for file_path in topology_dir.glob("*.yaml"):
                if file_path.name != "combined-topology.yaml":
                    yaml_files.append(file_path)
            
            for file_path in topology_dir.glob("*.yml"):
                if file_path.name != "combined-topology.yml":
                    yaml_files.append(file_path)
            
            if not yaml_files:
                print(f"⚠️  No YAML files found in {topology_path}")
                return None
            
            print(f"📋 Found {len(yaml_files)} YAML files: {[f.name for f in yaml_files]}")
            
            combined_content = []
            
            for yaml_file in sorted(yaml_files):
                print(f"📖 Reading: {yaml_file.name}")
                with open(yaml_file, 'r') as f:
                    content = f.read().strip()
                    if content:
                        combined_content.append(f"# From file: {yaml_file.name}")
                        combined_content.append(content)
                        combined_content.append("")
            
            combined_file = topology_dir / "combined-topology.yaml"
            with open(combined_file, 'w') as f:
                f.write('\n'.join(combined_content))
            
            print(f"✅ Created combined topology file: {combined_file}")
            return str(combined_file)
            
        except Exception as e:
            print(f"❌ Error consolidating topology files: {e}")
            return None
    
    def trigger_deployment(self, environment, env_config):
        """Trigger deployment to specific environment"""
        def run_deployment():
            try:
                print(f"🔄 Starting {environment} deployment...")
                
                # Change to git repo directory
                os.chdir('/opt/kafka_julie/git-repo/GITHUB_REPO')
                
                # Checkout the specific branch
                print(f"🔀 Switching to {env_config['branch']} branch...")
                checkout_result = subprocess.run(['git', 'checkout', env_config['branch']], 
                                               capture_output=True, text=True)
                
                if checkout_result.returncode != 0:
                    print(f"❌ Failed to checkout {env_config['branch']}: {checkout_result.stderr}")
                    return
                
                # Pull latest changes
                print(f"📥 Pulling latest changes from {env_config['branch']}...")
                git_result = subprocess.run(['git', 'pull', 'origin', env_config['branch']], 
                                          capture_output=True, text=True)
                
                if git_result.returncode == 0:
                    print(f"✅ Git pull successful: {git_result.stdout}")
                    
                    # Check if topology directory exists
                    if os.path.exists(env_config['topology_path']):
                        # Consolidate multiple YAML files
                        combined_file = self.consolidate_topology_files(env_config['topology_path'])
                        
                        if combined_file:
                            # Run Julie topology builder with combined file
                            print(f"🚀 Executing Julie for {environment} environment...")
                            julie_result = subprocess.run([
                                'java', '-jar', '/opt/kafka_julie/julie-ops-4.4.1.jar',
                                '--brokers', env_config['kafka_brokers'],
                                '--clientConfig', '/opt/kafka_julie/config/julie.properties',
                                '--topology', combined_file
                            ], capture_output=True, text=True)
                            
                            if julie_result.returncode == 0:
                                print(f"✅ {environment} deployment completed successfully!")
                                print(f"📋 Output: {julie_result.stdout}")
                                self.log_successful_deployment(environment, julie_result.stdout)
                            else:
                                print(f"❌ {environment} deployment failed: {julie_result.stderr}")
                                self.log_failed_deployment(environment, julie_result.stderr)
                        else:
                            print(f"❌ Failed to consolidate topology files for {environment}")
                    else:
                        print(f"⚠️  No topology directory found for {environment}: {env_config['topology_path']}")
                else:
                    print(f"❌ Git pull failed: {git_result.stderr}")
                    
            except Exception as e:
                print(f"❌ Deployment failed with exception: {e}")
        
        # Run in background thread
        threading.Thread(target=run_deployment, daemon=True).start()
    
    def log_pending_deployment(self, environment, payload):
        """Log deployment that requires manual approval"""
        timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        log_entry = {
            "timestamp": timestamp,
            "environment": environment,
            "status": "pending_approval",
            "commits": len(payload.get('commits', [])),
            "ref": payload.get('ref', ''),
            "manual_trigger_url": f"NGROK_URL_PLACEHOLDER/deploy/{environment}"
        }
        print(f"📝 Logged pending deployment: {json.dumps(log_entry, indent=2)}")
        print(f"🔗 Manual trigger: curl -X GET NGROK_URL_PLACEHOLDER/deploy/{environment}")
    
    def log_successful_deployment(self, environment, output):
        """Log successful deployment"""
        timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        print(f"✅ [{timestamp}] {environment} deployment successful")
        
    def log_failed_deployment(self, environment, error):
        """Log failed deployment"""
        timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        print(f"❌ [{timestamp}] {environment} deployment failed: {error}")
    
    def send_success_response(self, message):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = {"status": "success", "message": message}
        self.wfile.write(json.dumps(response).encode())
    
    def send_error_response(self, error):
        self.send_response(500)
        self.send_header('Content-type', 'application/json') 
        self.end_headers()
        response = {"status": "error", "message": error}
        self.wfile.write(json.dumps(response).encode())

if __name__ == '__main__':
    port = 8090
    server = HTTPServer(('0.0.0.0', port), GitOpsWebhookHandler)
    print(f"🎯 GitOps Multi-Environment Webhook started on port {port}")
    print(f"🔗 Webhook URL: NGROK_URL_PLACEHOLDER/webhook")
    print(f"❤️ Health check: NGROK_URL_PLACEHOLDER/health")
    print(f"📊 Status endpoint: NGROK_URL_PLACEHOLDER/status")
    print(f"🔧 Manual prod deploy: NGROK_URL_PLACEHOLDER/deploy/prod")
    print(f"")
    print(f"🏗️  Environment Configuration:")
    environments = GitOpsWebhookHandler.ENVIRONMENTS
    for env, config in environments.items():
        auto_status = "🤖 Auto-deploy" if config['auto_deploy'] else "👨‍💼 Manual approval"
        print(f"   • {env}: {config['branch']} branch → {auto_status}")
    print(f"")
    print(f"🎯 Key Features:")
    print(f"   • Branch-based GitOps (dev/stage/prod branches)")
    print(f"   • Detects only topology YAML changes in branch root")
    print(f"   • Combines multiple YAML files automatically")
    print(f"   • Logs all file changes for debugging")
    print(f"   • Manual trigger endpoint for prod")
    print(f"")
    server.serve_forever()