# Securing a Split KRaft Kafka Architecture: Setting Up Oauthbarer and SCRAM Authentication

In this demo, the main aim is to implement a split KRaft Kafka Cluster with separate controller and broker components. When authentication is added to the *.properties files, the split architecture can cause confusion, which is why I've set up OAUTHBARER authentication between the controller and broker. Additionally, a client container is included that uses both Oauthbarer and SCRAM authentication with the broker. For a deeper understanding of configuration, properties files, and Oauthbarer/SCRAM authentication, refer to check all configs folder.

---

### 🛠️ Environment Setup
| Software          | Description                                    | Version                             | UI - Ports      |
|-------------------|------------------------------------------------|-------------------------------------|------------|
| **WSL**           | Windows Subsystem for Linux environment        | Rockylinux 10 (Distro 2)             |            |
| **Docker**        | Containerization platform                      | Docker version 27.2.0               |            |
| **Docker Compose**| Tool for defining and running multi-container Docker applications | v2.29.2-desktop.2 |            |
| **Apache Kafka**  | Distributed event streaming platform           | 4.2.0                                | 9092 (broker), 9093 (controller) 19092-29092-39092 (external) |
| **KeyCloak**      | Network authentication protocol service        | 26.5.4                              | 8443 |
| **Java**         | Programming language                           | 21 with Scala-Cli Compiler                          |            |

---

### How to create Oauthbarer Client-ID and Scram Users for Client:
1. Check the `./add_users.sh` for Kafka Admin Manager.
```bash
╔════════════════════════════════════════════╗
║       Kafka Cluster Manager (OAuth)        ║
╚════════════════════════════════════════════╝

1) Create Topic
2) List Topics
3) Describe Topic
4) Create SCRAM User
5) Create OAuth Bearer User
6) List SCRAM Users
7) Add ACL
8) List ACLs
9) Add Consumer Group ACL
10) Exit

Choose [1-10]:
```

2. Also when you want to compile a jar or write a new scrip, you can put your file in `/configs/client/scripts`

client volume:
```bash
      - ./configs/client:/mnt/home
```

How to run client:
```bash
docker exec client scala-cli /mnt/scripts/producer.java
docker exec client scala-cli /mnt/scripts/consumer.java
```

Note: 
1. The producer.java client is already using the kafka-admin user, so you don’t need to create a new client ID. However, if you wish, of course, you can use `add_users.sh.`
2. ⚠️ Check main README.md file for how to start projects.
3. All metadata, data, and logs volumes are defined in the docker-compose.yaml. If you wish, you can uncommand the paths; the `logs` folder will be created automatically next to the docker-compose.yml file.