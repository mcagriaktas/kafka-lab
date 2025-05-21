# MULTI-KAFKA-DOCKER-SETUP

## ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
# ⚠️ UNDER MAINTENANCE ⚠️
## ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️

Hello everyone! This repository contains multi versions of Kafka along with a Kafka migration, upgrade and mirrormaker demo container. Each setup has its own folder with a dedicated README file, providing detailed instructions for setup and configuration.

In each folder, you’ll find `*.properties, *.yml`, `*.py`, `*.scala`, and `*.sh` files to guide you through each configuration step. The `Dockerfile in each setup builds Kafka images from scratch, making it easy to understand how Kafka is installed and configured`.

Additionally, this repository includes a setup for `Provectus Kafka UI`, a user-friendly interface for managing Kafka topics and brokers.

## ⚠️ Prerequisite: Start the .sh Script to Resolve Any Issues
First, run the deploying.sh script located in the following folders:
```bash
chmod +x deploying.sh

./deploying.sh

docker-compose up -d --build
```

## ⚠️ Prerequisite: Create a Docker Network
Create a Docker network to connect the containers:
```bash
docker network create --subnet=172.80.0.0/16 dahbest
```

After choosing the Kafka version you want to use, navigate to the relevant folder:
```bash
cd <kafka_version_folder>
```

Then, start the containers:
```bash
docker-compose up -d --build 
```

⚠️ Key Points:
- Versions 2.8.0 to 3.5.x: Both ZooKeeper and KRaft are supported.
- Version 3.5.x and beyond: ZooKeeper is deprecated, and KRaft is the only supported mode.
- Version 4.0.0 and later: ZooKeeper is completely removed, and only KRaft mode is available.
  
## Language and Systems Versions

| Component             | Version     |
|-----------------------|-------------|
| Kafka                 | 3.8.0 & 3.1.0 & 2.7.2       |
| Zookeeper             | 3.7.2       |
| KSQL                  | confluent-7.8.0 |
| Java                  | 11-jre-slim && 17-slim-bullseye |
| Python                | 3.10.12     |
| Scala                 | 2.12.18     |
| Scala Kafka-Clients Jar| 3.8.0       |
| Provectuse | v0.7.2 |
| Prometheus | 2.45.0 |
| Grafana | 10.4.14 |

