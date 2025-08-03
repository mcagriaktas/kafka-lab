# Kafka MirrorMaker 2

This repository offers a comprehensive lab environment for exploring active/passive Kafka replication using MirrorMaker 2. It supports various multi-cluster topologies and includes a modern management UI, making it easy to visualize and control your replication setup.

With this project, you can effortlessly simulate cross-cluster replication scenarios, test failover and recovery strategies, and observe the flow of messages between Kafka clusters in real time. The environment allows you to study how MirrorMaker 2 handles replication across clusters, manage topics and offsets, and experiment with different configurations.

This setup is ideal for developers, operators, and architects who want to gain hands-on experience with Kafka replication, validate disaster recovery plans, or analyze the behavior of distributed streaming systems under different network and cluster conditions. Everything needed to get started—including configuration files and monitoring tools—is provided for a smooth and insightful testing experience.

---

📁 Project Structure
```
.
├── configs/
│   ├── kafka/
│   │   ├── kafka1-a/ ... kafka3-b/      # Cluster A & B broker configs
│   ├── mirror_maker_properties/
│   │   ├── mm2-a.properties
│   │   ├── mm2-active-passive.properties
│   │   └── mm2-sasl_ssl_to_plain.properties
│   └── provectus/
│       └── config.yml
├── data_generator/
│   ├── producer.py
│   └── consumer.py
├── docker-compose.yml
├── images/
│   ├── kafka/
│   │   ├── Dockerfile
│   │   └── init-sh/
│   │       ├── kafka-export-starter.sh
│   │       └── kafka-starter.sh
│   └── provectus/
│       ├── Dockerfile
│       └── init-sh/
│           └── kafka-ui-starter.sh

```

---

## 🌐 Key Endpoints

| Service        | URL / Command                                   | Purpose                       |
|----------------|-------------------------------------------------|-------------------------------|
| Kafka UI       | [http://localhost:8080](http://localhost:8080)  | Topic and cluster management  |
| Source Kafka   | kafka{1,2,3}:9092, EXTERNAL: 19092, 29092, 39093| Cluster A brokers             |
| Dest Kafka     | kafka{1,2,3}:9092, EXTERNAL: 19091, 29091, 39091| Cluster B brokers             |
| MirrorMaker2   | CLI only                                        | See MM2 configs in `/configs/mirror_maker_properties` |

---

## What is MirrorMaker 2?
Kafka MirrorMaker 2 (MM2) is the official tool for replicating topics, configs, and even consumer groups across Kafka clusters.
This repo is pre-configured for active/passive replication—simulating disaster recovery, region failover, or cross-datacenter pipelines.
  - Active/Passive: All writes go to Cluster A. MM2 keeps Cluster B synchronized as a backup.
  - You can also test SASL_SSL to PLAINTEXT bridging and multi-cluster DR scenarios. (NOT SUPPORT THE DEPLOYMENT)

---

1. **Start the clusters:**
    ```bash
    docker-compose up -d --build
    ```

2. **Create topics on Cluster A using Kafka UI or CLI:**
    ```bash
    docker exec -it kafka1-a /opt/kafka/bin/kafka-topics.sh --create --topic cagri-topic --bootstrap-server kafka1-a:9092,kafka2-a:9092,kafka3-a:9092 --partitions 3 --replication-factor 2 --config min.insync.replicas=2
    ```

3. **Run data generator scripts:**
    ```bash
    python data_generator/producer.py
    ```

4. **Start MirroMaker2:**
    ```bash
    docker exec -it kafka1-a /opt/kafka/bin/connect-mirror-maker.sh /opt/kafka/config/mm2-active-passive.properties
    ```

5. **Check missing or dublicate data with scritps:**
    ```bash
    python data_generator/consumer.py
    ```

---

📝 Notes & Tips
 - Replication works one-way (active→passive) by default, but you can enable bidirectional or advanced topologies.
 - All broker config paths and volume mounts are defined in docker-compose.yml.
 - The Kafka UI lets you inspect both clusters and replicated topics.
 - Custom startup scripts are in each image’s init-sh/ folder.

## References

- [Confluent Documentation](https://docs.confluent.io/platform/current/installation/migrate-zk-kraft.html)
- [Microsoft Event Hubs Tutorial](https://learn.microsoft.com/tr-tr/azure/event-hubs/event-hubs-kafka-mirror-maker-tutorial)
- [Apache Kafka MirrorMaker Guide](https://medium.com/real-time-streaming/apache-kafka-mirror-maker-1400efeca94d)
- [HDInsight Kafka MirrorMaker 2.0 Guide](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/hdinsight/kafka/kafka-mirrormaker-2-0-guide.md)