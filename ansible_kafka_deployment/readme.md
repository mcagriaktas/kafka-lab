# Kafka Cluster Ansible Deployment

This documentation covers the setup and management of a Kafka cluster using Ansible playbooks.

Important Info:
1. `This deployment supports only the KRaft Kafka version.`
2. `Each broker's server.properties file must be placed in a separate folder within the config directory.`
   
## Directory Structure

```
ansible-deployment/
├── play-books/
│   ├── config/
│   │   ├── broker-1/
│   │   │   └── server.properties
│   │   └── broker-2/
│   │   │   └── server.properties
│   ├── user_ssh_keys/
│   │   ├── kafka_user
│   │   └── kafka_user.pub
│   ├── hosts
│   ├── vars.yml
│   ├── install.yml
│   ├── uninstall.yml
│   ├── start.yml
│   ├── stop.yml
│   ├── restart.yml
│   ├── status.yml
│   └── format.yml
```

## Deployment Methods

### 1. Root User Deployment

`hosts` configuration:
```ini
[broker1]
server1 ansible_host=192.168.1.108 ansible_become=yes ansible_become_method=sudo ansible_user=kafka

[broker2]
server2 ansible_host=192.168.1.105 ansible_become=yes ansible_become_method=sudo ansible_user=kafka

[all:vars]
ansible_ssh_private_key_file=/home/ubuntu1/ansible-deployment/play-books/user_ssh_keys/kafka_user
```

`vars.yml` configuration:
```yaml
enable_sudo: true
```

Deploy command:
```bash
ansible-playbook -i hosts install.yml --ask-become-pass
```

### 2. Non-Root User Deployment

`hosts` configuration:
```ini
[broker1]
server1 ansible_host=192.168.1.108 ansible_become=no ansible_become_method=sudo ansible_user=kafka

[broker2]
server2 ansible_host=192.168.1.105 ansible_become=no ansible_become_method=sudo ansible_user=kafka

[all:vars]
ansible_ssh_private_key_file=/home/ubuntu1/ansible-deployment/play-books/user_ssh_keys/kafka_user
```

`vars.yml` configuration:
```yaml
enable_sudo: false
```

Manual Directory Setup Required:
```bash
sudo mkdir /opt/kafka
sudo chown -R kafka:kafka /opt/kafka
sudo chmod 755 /opt/kafka
```

Deploy command:
```bash
ansible-playbook -i hosts install.yml
```

## Initial Setup Steps

1. Create kafka user and setup SSH:
```bash
sudo useradd -m -d /home/kafka kafka
sudo mkdir -p /home/kafka/.ssh
sudo chmod 700 /home/kafka/.ssh
```

2. Copy SSH keys:
```bash
scp kafka_user.pub ubuntu@server:/tmp/kafka_key.pub
ssh ubuntu@server "sudo mv /tmp/kafka_key.pub /home/kafka/.ssh/authorized_keys"
sudo chown kafka:kafka /home/kafka/.ssh/authorized_keys
sudo chmod 600 /home/kafka/.ssh/authorized_keys
```

## Available Playbooks

- `install.yml`: Installs Kafka
- `format.yml`: Formats Kafka storage
- `start.yml`: Starts Kafka cluster
- `stop.yml`: Stops Kafka cluster
- `restart.yml`: Restarts Kafka cluster
- `status.yml`: Checks Kafka cluster status
- `uninstall.yml`: Removes Kafka installation

## Common Issues and Solutions

### SSH key passphrase prompts:
```bash
eval $(ssh-agent -s)
ssh-add user_ssh_keys/kafka_user
```

### Sudo password prompts:
- Use --ask-become-pass flag with root deployment

### Port check failures:
- Ensure correct IP addresses in server.properties
- Verify port availability

### Format errors:
- Check existing cluster ID
- Use format.yml with --ignore-formatted flag
