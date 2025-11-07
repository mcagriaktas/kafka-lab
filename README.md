# KAFKA-LAB

A comprehensive Apache Kafka laboratory environment featuring multiple deployment scenarios. This repository primarily focuses on all Kafka components. Each deployment includes its own Dockerfile. These Dockerfiles are not intended for production use, as they are optimized for real Linux machines. For this reason, you can follow the instructions in each Dockerfile and deploy them on your own virtual machine (e.g., a Linux VM using Oracle VirtualBox).

Also, check the logs folder. When you create a topic or interact with any Kafka component, you can monitor what's happening in the background. This makes it easy to understand and troubleshoot by following the logs.

There is two deployment with SASL_SSL authentication, located in the folder named `kafka_split_kraft_with_kerberos_scram` and `kafka_split_kraft_with_only_scram`. I include fast deployment options for authentication types like SASL_PLAINTEXT because the main goal of this repository is to understand each Kafka component and how to deploy and use them effectively, the folder name is `kafka_split_kraft_with_sasl_plaintext`.


<img width="512" height="512" alt="kafka-lab-icon" src="https://github.com/user-attachments/assets/ed69edf1-a774-4e4e-9bf3-c7c68aae92d5" />

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