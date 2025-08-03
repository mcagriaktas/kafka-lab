#!/bin/bash

set -e

echo "Starting automated ngrok setup..."

# Validate required environment variables
if [[ -z "$ngrok_token" ]] || [[ -z "$github_username" ]] || [[ -z "$github_email" ]] || [[ -z "$github_repo" ]] || [[ -z "$github_token" ]] ; then
    echo "❌ Missing required environment variables"
    exit 1
else 
    echo "✅ All required environment variables are set"
fi

# Configure ngrok auth token
echo "Configuring ngrok..."
sed "s|ngrok_token|$ngrok_token|g" /opt/ngrok_tunnel/ngrok.yml.template > /root/.config/ngrok_tunnel/ngrok.yml

# Start ngrok in background
echo "Starting ngrok tunnel..."
/opt/ngrok_tunnel/ngrok start --config /root/.config/ngrok_tunnel/ngrok.yml app > /opt/ngrok_tunnel/logs/ngrok.log 2>&1 &

# Wait for ngrok to start and get URL
echo "Waiting for ngrok tunnel to establish..."
sleep 5

# Get ngrok URL using API
ngrok_url=""
for i in {1..5}; do
    ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null)
    if [[ $ngrok_url != "null" ]] && [[ $ngrok_url != "" ]]; then
        echo "✅ Ngrok URL obtained: $ngrok_url"
        break
    fi
    echo "⏳ Waiting for ngrok... (attempt $i/5)"
    sleep 2
done

if [[ $ngrok_url == "null" ]] || [[ $ngrok_url == "" ]]; then
    echo "❌ Failed to get ngrok URL, using placeholder"
    exit 1
fi

# Update Python webhook script with ngrok URL
echo "Updating webhook script with ngrok URL..."
cp /opt/kafka_julie/webhook-listener.py /opt/kafka_julie/webhook-listener.py.backup
cat /opt/kafka_julie/webhook-listener.py.backup | \
    sed -e "s|NGROK_URL_PLACEHOLDER|$ngrok_url|g" -e "s|GITHUB_REPO|$github_repo|g" > /opt/kafka_julie/webhook-listener.py

echo "Deploying GitHub Actions machine..."
# Create directory
cd /opt/kafka_julie/git-repo

# Configure git
git config --global user.name "$github_username"
git config --global user.email "$github_email"

git clone https://$github_username:$github_token@github.com/$github_username/$github_repo.git
if [[ $? -ne 0 ]]; then
    echo "❌ Failed to clone repository"
    exit 1
else
    echo "✅ Repository cloned successfully"
fi

# Start GitHub Webhook Listener
echo "Starting GitHub Webhook Listener..."

touch /opt/kafka_julie/logs/webhook.log
chmod 777 /opt/kafka_julie/logs/webhook.log

#python3 /opt/kafka_julie/webhook-listener.py
python3 -u /opt/kafka_julie/webhook-listener.py 2>&1 | tee -a /opt/kafka_julie/logs/webhook.log