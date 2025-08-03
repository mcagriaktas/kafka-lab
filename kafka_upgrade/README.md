# Kafka Upgrade Guide from 3.7.0 to 3.8.0 (KRaft - Zookeeper)

This repository offers a comprehensive Kafka upgrade laboratory designed to help you learn and practice rolling upgrades from Kafka 3.7.0 to 3.8.0. The environment is fully equipped to support both ZooKeeper-based and KRaft (Kafka Raft Metadata) mode clusters, reflecting real-world upgrade scenarios.

With this project, developers and engineers can perform and validate safe, zero-downtime Kafka upgrades in a controlled, automated setting. The lab is ideal for understanding feature versioning, managing compatibility, and testing the impact of upgrades on live clusters. You can simulate the full upgrade process, explore new Kafka features, and gain hands-on experience with both coordination modes—ensuring you are well-prepared for production upgrades.

This setup provides all necessary scripts, configuration files, and step-by-step instructions to guide you through each stage of the upgrade process, making it easy to test your skills, verify your strategies, and achieve successful Kafka version transitions with confidence.

---

## 📁 Project Structure

```
.
├── docker-compose.yml              # Main cluster orchestration
├── data_generator/
│   └── producer.py                 # Sample producer for test data
├── configs/
│   ├── kafka_3.7.0/                # Kafka 3.7.0 configs (ZooKeeper & KRaft)
│   ├── kafka_3.8.0/                # Kafka 3.8.0 configs (ZooKeeper & KRaft)
│   └── zookeeper/                  # ZooKeeper config
├── grafana/
│   └── dashboards/                 # Grafana monitoring dashboards
├── scripts/
│   └── rolling_upgrade.sh          # Sample upgrade automation script
└── README.md
```

---

## 🌐 Key Endpoints

| Service            | URL / Command                          | Notes                                |
|--------------------|----------------------------------------|--------------------------------------|
| Kafka UI           | [http://localhost:8080](http://localhost:8080)   | Topic and cluster management         |
| Grafana            | [http://localhost:3000](http://localhost:3000)   | Visualization & dashboards           |
| ZooKeeper (if used)| `localhost:2181`                       | ZooKeeper ensemble                   |
| Kafka 3.7.0 Broker | `localhost:9192`                       | Before upgrade                       |
| Kafka 3.8.0 Broker | `localhost:9292`                       | After upgrade                        |

---

## 📊 What is Kafka Upgrade?

A **Kafka upgrade** is the process of moving a running Kafka cluster from one version to another (here, 3.7.0 → 3.8.0) **without downtime or data loss**. This includes:
- Upgrading cluster software (binaries & configs)
- Carefully updating protocol and metadata versions
- Verifying with test traffic and monitoring
- Optionally upgrading ZK to KRaft mode

Kafka upgrades require careful order of operations: brokers, then controllers, then config changes. You can monitor health and traffic with Grafana at every step.

---

## ⚡ Quick Start

1. **Start the Kafka Lab:**
   ```bash
   docker-compose up -d --build
   ```

--- 

### Notes:
- **Kafka 2.8.0 to 3.5.x**: Both ZooKeeper and KRaft are supported.
- **Kafka 3.5.x+**: ZooKeeper is deprecated; KRaft is the only supported mode.
- **Kafka 4.0.0+**: ZooKeeper is completely removed; only KRaft is supported.

### Versions Used in This Lab:
| Component          | Version     |
|--------------------|-------------|
| New Kafka          | 3.8.0       |
| Old Kafka          | 3.7.0       |
| ZooKeeper          | 3.7.2       |

---

## Quick Start

1. **Create Docker Network:**
    ```bash
    docker network create --subnet=172.80.0.0/16 dahbest
    ```

2. **Start the Kafka Cluster:**
    ```bash
    docker-compose up -d --build
    ```

    > 📝 **Note**: This lab simulates a Linux VM environment. All Kafka versions and tools are pre-installed inside Docker containers.

## Confluent Kafka Version Mapping

| Confluent Platform Version | Kafka Broker Protocol Version     |
|----------------------------|-----------------------------------|
| 8.0.x                      | `inter.broker.protocol.version=4.0` |
| 7.9.x                      | `inter.broker.protocol.version=3.9` |
| 7.8.x                      | `inter.broker.protocol.version=3.8` |
| 7.7.x                      | `inter.broker.protocol.version=3.7` |
| 7.6.x                      | `inter.broker.protocol.version=3.6` |
| 7.5.x                      | `inter.broker.protocol.version=3.5` |
| 7.4.x                      | `inter.broker.protocol.version=3.4` |
| 7.3.x                      | `inter.broker.protocol.version=3.3` |
| 7.2.x                      | `inter.broker.protocol.version=3.2` |
| 7.1.x                      | `inter.broker.protocol.version=3.7` |
| 7.0.x                      | `inter.broker.protocol.version=3.0` |

| Confluent Platform Version | Kafka Metadata Versions          |
|----------------------------|----------------------------------|
| 8.0.x                      | `4.0-IV0`                        |
| 7.9.x                      | `3.9-IV0`                        |
| 7.8.x                      | `3.8-IV0`                        |
| 7.7.x                      | `3.7-IV0` through `3.7-IV4`      |
| 7.6.x                      | `3.6-IV0` through `3.6-IV2`      |
| 7.5.x                      | `3.5-IV0` through `3.5-IV2`      |
| 7.4.x                      | `3.4-IV0`                        |
| 7.3.x                      | `3.3-IV0` through `3.3-IV3`      |

---

## Important Notes

- `log.message.format.version` is only used for Kafka versions **before 3.3**.
- If you're running **split mode (brokers and controllers separated)**, upgrade brokers **first**, then controllers.
- **KRaft Upgrade After 3.8.0**: Add `CONTROLLER` to `advertised.listeners`:
  ```properties
  advertised.listeners=BROKER://kafka1:9092,CONTROLLER://kafka1:9093,LISTENER_DOCKER_EXTERNAL://localhost:19092
  ```

---

## Upgrade Steps

### ZooKeeper Cluster Upgrade

1. **Start the ZooKeeper Cluster** (automatically started with Docker Compose).
2. **Check Kafka Cluster Version**:
   ```bash
   docker exec -it kafka1 bash
   /mnt/kafka_2.13-3.8.0/bin/kafka-features.sh --bootstrap-controller localhost:9093 describe
   ```
3. **Create a Topic**:
   - Use Kafka UI (`localhost:8080`) to create a topic with:
     - Name: `test`
     - Partitions: `12`
     - Replication Factor: `3`
     - Min In-Sync Replicas: `2`
4. **Run Sample Data Generator**:
   ```bash
   python data_generator/producer.py
   ```
5. **Stop Kafka 3.7.0** (one broker at a time):
   - Use `Ctrl+C` or:
     ```bash
     /mnt/kafka_2.13-3.7.2/bin/kafka-server-stop.sh
     ```
6. **Start Kafka 3.8.0**:
   ```bash
   /mnt/kafka_2.13-3.8.0/bin/kafka-server-start.sh /mnt/properties/zoo_server.properties
   ```
7. **Upgrade Metadata Version**:
   ```bash
   /mnt/kafka_2.13-3.8.0/bin/kafka-features.sh --bootstrap-controller localhost:9093 upgrade --metadata 3.8-IV0
   ```

---

### KRaft Cluster Upgrade

1. **Add Required Config in `server.properties`**:
   ```properties
   inter.broker.protocol.version=3.7
   ```
2. **Start KRaft Kafka 3.7.0**:
   ```bash
   /mnt/kafka_2.13-3.7.2/bin/kafka-server-start.sh /mnt/properties/kraft_server.properties
   ```
3. **Check Metadata Version**:
   ```bash
   /mnt/kafka_2.13-3.8.0/bin/kafka-features.sh --bootstrap-controller localhost:9093 describe
   ```
4. **Create a Topic via Kafka UI**:
   - Use Kafka UI (`localhost:8080`) to create a topic with:
     - Name: `test`
     - Partitions: `12`
     - Replication Factor: `3`
     - Min In-Sync Replicas: `2`
5. **Stop Kafka 3.7.0** (one broker at a time):
   ```bash
   /mnt/kafka_2.13-3.7.2/bin/kafka-server-stop.sh
   ```
6. **Update `server.properties`**:
   ```properties
   inter.broker.protocol.version=3.8
   ```
7. **Start KRaft Kafka 3.8.0**:
   ```bash
   /mnt/kafka_2.13-3.8.0/bin/kafka-server-start.sh /mnt/properties/kraft_server.properties
   ```
8. **Upgrade Metadata Version**:
  - Step to step each controller:
   ```bash
   /mnt/kafka_2.13-3.8.0/bin/kafka-features.sh --bootstrap-controller localhost:9093 upgrade --metadata 3.8-IV0
   ```

---

## 📚 References
- [Apache Kafka Documentation - Upgrade Guide](https://kafka.apache.org/documentation/#upgrade)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [KRaft Mode](https://kafka.apache.org/documentation/#kraft)
- [Zero-Downtime Upgrades](https://www.confluent.io/blog/kafka-rolling-upgrade-no-downtime/)

---