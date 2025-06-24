# GitOps Kafka Management with JulieOps

Manage Kafka topologies (topics, ACLs, configs, Consumer Groups etc.) using GitOps principles with JulieOps. This demo shows how to automate Kafka configuration through Git workflows with branch - based environments.

> **Medium Article**: [How to Manage Kafka Topology with JulieOps]([https://medium.com/p/your-article-link](https://medium.com/@mucagriaktas/how-to-manage-kafka-topology-with-julieops-4903594b0307))

![image](https://github.com/user-attachments/assets/af496444-7f3b-4e74-aeaf-2f8b9602aef0)

## ⚡️ Core Features
- Declarative Kafka configuration via YAML files
- Environment segregation (dev/stage/prod)
- Webhook-driven GitOps automation
- Approval workflow for production changes
- Kafka UI for monitoring
- Custom Docker setup for all components

## 🧩 Services Overview

| Service Name      | Version | Description             | URLs                 | Ports  |
|-------------------|---------|--------------------------|----------------------|--------|
| Kafka             | 4.0.0   | Streaming platform       | kafka{1, 2, 3}:9092 | localhost:{19092, 29092, 39092} | Inside:9092, Outside:{19092, 29092, 39092}   |
| Kafka UI          | 0.7.2  | Web-based Kafka viewer   | http://localhost:8080| 8080   |
| Kafka JulieOps    | 4.4.1  | Kafka topology manager   | -                  | -   |
| Ngrok             | v3-stable-linux-amd64  | Tunnel to localhost      | http://localhost:4040| 4040   |
| Webhook Listener  | Python3  | GitHub webhook handler   | 0.0.0.0                | 8090   |

## 🛠 Project Structure
```bash
├── config
│   ├── kafka-julie
│   │   ├── julie.properties
│   │   └── ngrok.yml.template
│   ├── kafka1
│   │   ├── kafka-metrics.yml
│   │   └── server.properties
│   ├── kafka2
│   │   ├── kafka-metrics.yml
│   │   └── server.properties
│   ├── kafka3
│   │   └── server.properties
│   ├── provectus
│   │   └── config.yml
│   └── team-a
│       ├── configs
│       │   └── push_yaml_to_repo.md
│       └── topologies
│           ├── dev
│           │   └── dev-topologies.yaml
│           ├── prod
│           │   └── prod-topologies.yaml
│           └── stage
│               └── stage-topology.yaml
├── container_images
│   ├── kafka
│   │   ├── Dockerfile
│   │   └── init-sh
│   │       └── kafka-starter.sh
│   ├── kafka-julie
│   │   ├── Dockerfile
│   │   └── init-sh
│   │       ├── kafka-julie-starter.sh
│   │       ├── ngrok.yaml
│   │       └── webhook-listener.py
│   ├── provectus
│   │   ├── Dockerfile
│   │   └── init-sh
│   │       └── starter-kafka-ui.sh
│   └── team-a
│       ├── Dockerfile
│       └── init-sh
│           └── machine-starter.sh
├── docker-compose.yml
└── logs
```


## 🚀 Quick Start
### Prerequisites
- Linux
- Docker & Docker Compose
- GitHub account
- [Ngrok account](https://ngrok.com) (free tier)

### Setup
1. **Clone the repository**:
```bash
git clone $REPO_URL
cd kafka-julie-ops
```

2. **Configure environment**:
```bash
# GitHub Configuration
github_username=your_github_username
github_email=your_github_email
github_repo=your_github_repository
github_token=your_classic_github_token

# Ngrok Configuration
ngrok_token=your_ngrok_token
```

3. **Create Docker network**:
```bash
docker network create --subnet=172.80.0.0/16 dahbest
```

4. **Build and start the demo**:
```bash
docker-compose up -d
```

## ⚠️ Tips:

1. **Accept the commit for the PROD environment**:

You can find your ngrok_url in `/logs/kafka-julie/` or by running `docker logs kafka-julie`.
```bash
curl -X GET $NGROK_URL$/deploy/prod
```

2. **How to push topologies from the team-a container to GitHub**:

Think of it as a machine in your company, and another team wants to create or update a topic, etc.

```bash
cd /mnt

git clone $repo_url

git branch dev
```

Then create a YAML file, you can find an example in the `/topologies` folder.

```bash
git add your_yaml.yaml

git commit -m "first topic"

git push origin dev 
```

then check `docker logs kafka-julie` and `kafka-ui (localhost:8080)`

## Source:
- [Kafka Julie Github Repo](#https://github.com/kafka-ops/julie)
- [Kafka Julie Docs](#https://julieops.readthedocs.io/en/3.x/index.html)
