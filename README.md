# KAFKA-LAB

A comprehensive Apache Kafka laboratory environment featuring multiple deployment scenarios. This repository primarily focuses on all Kafka components. Each deployment includes its own Dockerfile. These Dockerfiles are not intended for production use, as they are optimized for real Linux machines. For this reason, you can follow the instructions in each Dockerfile and deploy them on your own virtual machine (e.g., a Linux VM using Oracle VirtualBox).

Also, check the logs folder. When you create a topic or interact with any Kafka component, you can monitor what's happening in the background. This makes it easy to understand and troubleshoot by following the logs.

There is two deployment with SASL_SSL authentication, located in the folder named `kafka_split_kraft_with_kerberos_scram` and `kafka_split_kraft_with_only_scram`. I include fast deployment options for authentication types like SASL_PLAINTEXT because the main goal of this repository is to understand each Kafka component and how to deploy and use them effectively, the folder name is `kafka_split_kraft_with_sasl_plaintext`.


<img width="512" height="512" alt="kafka-lab-icon" src="https://github.com/user-attachments/assets/ed69edf1-a774-4e4e-9bf3-c7c68aae92d5" />

---

## 🗺️ Deployment Scenarios

### Core Kafka Deployments

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_zookeeper** | Traditional Kafka with ZooKeeper coordination | Kafka 3.8.0, ZooKeeper 3.7.2 | ⭐ | Test Deployment |
| **kafka_kraft_3_broker** | Modern KRaft cluster (3 brokers) | Kafka 4.0.0 KRaft | ⭐⭐ | Test Deployment |
| **kafka_kraft_full_deployment** | Enhanced KRaft with monitoring and CI/CD | Kafka 4.0.0, Prometheus, Grafana, KSQLDB, Jenkins, Burrow, Lag Exporter | ⭐⭐⭐ | Test Deployment |

### Security & Authentication

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_split_kraft_with_kerberos_scram** | Enterprise security implementation | Kerberos KDC, SASL_SSL, SCRAM authentication, JKS TLS config | ⭐⭐⭐⭐⭐ | Enterprise Deployment |
| **kafka_split_kraft_with_only_scram** | Enterprise security implementation  | SASL_SSL, SCRAM-only auth, JKS TLS config| ⭐⭐⭐⭐⭐      | Enterprise Deployment |            |
| **kafka_split_kraft_with_sasl_plaintext**     | Lightweight secure KRaft deployment | SASL_PLAINTEXT | ⭐⭐⭐⭐       | Test Deployment |

### Data Integration & CDC

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_debezium** | Change Data Capture pipeline | Debezium 3.1.1, PostgreSQL 16, Prometheus | ⭐⭐⭐ | Real-time data streaming |
| **kafka_connector** | Kafka Connect with external systems | Kafka Connect, Couchbase connector, Kafka KCCTL | ⭐⭐⭐⭐ | Data integration |
| **kafka_schema_registry** | Schema management and evolution | Confluent Schema Registry, Avro examples | ⭐⭐⭐⭐ | Schema governance |

### Stream Processing

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_flink_sql** | Real-time stream processing | Apache Flink 2.0.0, SQL interface, SQL Gateway, Grafana, Prometheus, Lag Exporter | ⭐⭐⭐⭐ | Real-time analytics |

### Monitoring & Observability

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_burrow** | Consumer lag monitoring | LinkedIn Burrow 0.4.0, Grafana dashboards, Prometheus | ⭐⭐⭐ | Consumer monitoring |

### Operations & Management

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_cruise_control_cc_ui** | Automated cluster management | LinkedIn Cruise Control 3.0.3, Web UI | ⭐⭐⭐⭐ | Cluster optimization |
| **kafka_julie_ops** | GitOps for Kafka topology | JulieOps 4.4.1, webhook integration, GitHub Deployment | ⭐⭐⭐⭐ | Infrastructure as Code |
| **kafka_mirror_maker** | Cross-cluster replication | Kafka MirrorMaker 2.0, multi-cluster setup | ⭐⭐⭐ | Disaster recovery |

### Migration & Upgrades

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_migration_zk_to_kraft** | ZooKeeper to KRaft migration | Migration tools, step-by-step process | ⭐⭐⭐⭐ | Production migration |
| **kafka_upgrade** | Version upgrade scenarios | Multiple Kafka versions, migration tools | ⭐⭐⭐ | Version management |

### Performance & Testing

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_jmeter_kloadgen** | Load testing framework | JMeter, KLoadGen plugin, Schema Registry, Grafana, Prometheus | ⭐⭐⭐ | Performance validation |

### Infrastructure as Code

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_terraform_k8s** | Kubernetes deployment | Terraform, K8s manifests, Dockerfile | ⭐⭐⭐⭐ | Cloud-native deployment |
| **kafka_ansible** | Bare-metal automation | Ansible playbooks, SSH key management | ⭐⭐⭐ | Enterprise automation |

### Development Tools

| Folder | Description | Components | Complexity | Use Case |
|--------|-------------|------------|------------|----------|
| **kafka_scripts** | Client examples and utilities | Python/Scala producers/consumers | ⭐ | Development reference |

## 🔧 Component Version Matrix

| Component | Versions Used | Purpose |
|-----------|---------------|---------|
| **Apache Kafka** | 3.8.0, 4.0.0 | Core streaming platform |
| **Apache ZooKeeper** | 3.7.2 | Legacy coordination service |
| **Confluent KSQLDB** | Confluent 8.0.0 | SQL streaming interface |
| **Kafka KCCTL** | 1.0.0.CR4 | Kafka Connector Tool |
| **Confluent Schema Registry** | Confluent 8.0.0 | Schema management |
| **Kafka Connect Couchbase** | 4.2.6 | Kafka Connector |
| **Apache Flink** | 2.0.0 | Stream processing engine |
| **Kafka-UI (Prometheus)** | v0.7.2 | Web management interface |
| **Prometheus** | 2.45.0 | Metrics collection |
| **Burrow** | 0.4.0 | Consumer lag monitoring |
| **Lag Exporter** | 1.9.0 | Consumer lag monitoring |
| **Grafana** | 10.4.14 | Metrics visualization |
| **Terraform** | Latest | Infrastructure as Code (IaC) tool |
| **Kubernetes** | Latest | Container orchestration platform |
| **Jenkins** | 2.506 | CI/CD automation server |
| **JulieOps** | 4.4.1 | Kafka topology management |
| **Debezium** | 3.1.1.Final | Change Data Capture |
| **Cruise Control** | 3.0.3 | Cluster balancing |
| **Cruise Control UI** | Latest | Web management interface |
| **Kerberos** | 1.19.2-2ubuntu0.5 | Network authentication protocol service MIT Kerberos version |
| **Jmeter** | 5.6.3 | 	Performance testing tool |
| **PostgreSQL** | 16 | CDC source database |
| **Couchbase** | 7.6.4 | NoSQL connector target |
| **Python** | 2.10+ | Consumer / Producer Scripts |
| **Scala** | 3+ | Consumer / Producer Scripts |

---


## 🔧 Prerequisites

### Required Software
- **Docker & Docker Compose** 28.3.0
- **Docker Compose**  v2.38.1
- **Linux/WSL Environment** 20.04+

### Hardware Requirements
| Deployment Type | RAM | CPU | Storage |
|----------------|-----|-----|---------|
| Single Broker | Max: 6GB | 2 cores | 10GB |
| Multi-Broker | Max: 18GB+ | 4 cores | 20GB+ |
| Full Stack | Max: 24GB+ | 6 cores | 30GB+ |

---

## 📦 About Kafka Deployment
**In all Kafka deployments, the architecture is nearly the same. Here's how it's structured based on the Dockerfile:**
1. **Kafka Version is defined.**
2. **Kafka-related environment variables are set, including:**
    - `KAFKA_HOME`
    - `KAFKA_DATA_HOME`
    - `KAFKA_VERSION`
    - `KAFKA_OPTS`
    - `KAFKA_HEAP_OPTS`
    - `KAFKA_JMX_OPTS`
3. **None of the Dockerfiles use CMD or ENTRYPOINT directly. Instead, a kafka-starter.sh script is used to handle the deployment logic in a customizable way.**
4. **There is no dedicated Kafka user, as this setup is intended for testing purposes.**

## ▶️ How to Run Deployments

1. **Create External Docker Network:**
    ```bash
    docker network create --subnet=172.80.0.0/16 dahbest
    ```

2. **Choose Your Deployment Scenario:**
    Starter: Basic Kafka Cluster Setup
    ```bash
    cd any_folder && docker-compose up -d --build
    ```

---

## Important For Fresh Cluster Setup
```text
⚠️ If the cluster has already been started and you want to reset it as a fresh cluster, you must delete the logs directory:

sudo rm -rf logs/*
```

## Advanced Configuration Patterns

### Monitoring Stack Features
- **JMX metrics export** from all brokers
- **Custom Grafana dashboards** for cluster health
- **Log aggregation** with structured logging

### Security Implementation
- **SASL_SSL authentication** with Kerberos/Scram
- **SASL_SSL authentication** with only Scram-256
- **SASL_PLAINTEXT authentication** with only PLAIN
- **ACL-based authorization** with fine-grained permissions

---

## 🤝 Contributing

Contributions welcome! Welcome to pull requests for:
- New deployment scenarios
- Performance optimizations
- Documentation improvements
- Bug fixes

---

## 🎯 Roadmap

- [✅] **CI/CD Pipelines:** Automated testing and deployment
- [✅] **Security Hardening:** Production-grade security configurations
- [✅] **Kafka Streams Examples:** Stream processing scenarios
- [🚧] **LLM integration with Kafka:** Analyze complex streaming logs using LLM and visualize them with Grafana. (IN DEPLOYMENT)
- [🚧] **Active-Passive Senerio:** Implement failover and redundancy mechanisms (IN DEPLOYMENT)
- [🔲] **Multi-Cloud Deployments:** AWS, GCP, Azure deployment scenarios

---

## Resources

### Official Documentation
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kafka Operations Guide](https://kafka.apache.org/documentation/#operations)
- [KRaft Mode Documentation](https://kafka.apache.org/documentation/#kraft)

### Community Resources
- [Confluent Developer Hub](https://developer.confluent.io/)
- [Kafka Improvement Proposals (KIPs)](https://cwiki.apache.org/confluence/display/kafka/kafka+improvement+proposals)
- [Apache Kafka Users Mailing List](https://kafka.apache.org/contact)
- [Apache Kafka Zookeeper to KRaft Migration](https://strimzi.io/blog/2024/03/22/strimzi-kraft-migration/)
---

**Made with ❤️ for the Apache Kafka and Open Source community**

> **Note:** This repository has been developed over 7-8 months during evening hours. If you notice any issues or have suggestions for improvements, please open an issue or submit a pull request. Your contributions help make this resource better for everyone!