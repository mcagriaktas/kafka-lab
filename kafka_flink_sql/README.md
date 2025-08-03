# Kafka and Flink SQL - Streaming Deployment

This repository provides a complete streaming analytics pipeline built with Apache Kafka and Apache Flink SQL. The environment is designed to showcase how real-time data streaming, processing, and analytics can be achieved using these powerful open-source technologies.

In addition to the core Kafka and Flink components, the stack includes Prometheus and Grafana for full observability and monitoring of your data pipeline. With integrated dashboarding features, you can easily visualize metrics, monitor system health, and track the flow of streaming data through your pipeline.

The setup includes all necessary configurations for running both Apache Kafka and Flink jobs, enabling you to ingest, process, and analyze data streams in real time. Whether you are exploring streaming analytics, building real-time applications, or seeking a reference architecture for modern data processing, this repository offers a practical, end-to-end solution for deploying, observing, and managing data streaming workloads.

- [All details are in the Medium article — click the link and check all the explanations.](https://medium.com/@mucagriaktas/ed2f483d05e0)

## ⚙️ Services & Versions

This project implements a complete streaming data pipeline with the following components:

| Service | Version | Description | Ports | User & Password
|---------|---------|-------------|--------| -------------|
| Apache Kafka | 4.0.0 | Distributed event streaming platform (3-node cluster) | Inside: 9092, Outside: 19092,29092,39093 | - |
| Kafka Exporter | 1.9.0 | Kafka Consumer Metrics Exporter | 9308 | - |
| Apache Flink | 1.20.0 | Stateful stream processing framework with SQL support (Jobmanager, Taskmanager and SQL-Gateway) | UI: 8081, SQL-Gateway: 8082 | - |
| Prometheus | 2.45.0 | Monitoring system | 9090 | - |
| Provectus | 0.7.2 | Web interface for Kafka management | 8080 | - |
| Grafana | 10.4.14 | Monitoring and visualization (3 dashboard) | 3000 | User: admin, Password: 3541 |

## 📂 Project Structure
```bash
├── docker-compose.yml
├── config/
│   ├── flink/              # Job/TaskManager configs
│   ├── kafka/              # Broker configs & metrics & Kafka-exporter
│   ├── grafana/            # Dashboards & datasource setup
│   ├── prometheus/         # prometheus.yaml config
│   └── provectus/          # Kafka UI config
├── images/                 # All Dockerfiles + init-sh scripts
├── jobs/
│   ├── flink/              # SQL scripts for streaming
│   └── raw_data.py         # Python generator for Kafka input
├── repo_images/            # Dashboard screenshots
└── README.md
```

### 📁 Service Startup Automation
Each image in the `images/` folder includes its own `service_name-starter.sh` script.
These `starter.sh` scripts are designed to automate deployment and setup for each service — such as:

- ⚙️ Initializing Jenkins jobs
- 📊 Preloading Grafana dashboards
- 🚀 Auto-starting services with correct configs

They simplify the deployment process and ensure everything is ready out-of-the-box.

### 🐳 Deployment Tip
You can also deploy each service individually on any Linux server by following the corresponding Dockerfile. Each Dockerfile includes step-by-step instructions to build and configure the service easily.

## Deployment

### 1. Build and Deploy

```bash
docker-compose up -d --build
```

> ⚠️ The build process will take approximately 2-3 minutes since all services are built from scratch rather than using base images.

## Getting Started

### 1. Create Kafka Topics

Access Kafka UI at `http://localhost:8080` then create topics:
- Create `raw-data` topic
- Create `clean-data` topic
- Create `raw-data-dlq` topic

### 2. Configure Flink SQL Processing

Run the `Flink-SQL-Manager` job in Jenkins UI and paste the SQL queries from:
- `jobs/flink/etl.sql` - For data transformation

```bash
docker exec -it jobmanager /opt/flink/bin/sql-client.sh gateway --endpoint http://jobmanager:8082 -f /opt/flink/jobs/etl.sql
```

### 3. Start Data Producer

Run the sample data producer:
```bash
python jobs/raw_data.py
```

> ⚠️ The datagenerator generates 1 error message for every 10 messages to demonstrate that a single SQL file can be used for multiple tasks. 
1. Consume Kafka `raw-data` topic. 
2. Producer Kafka `clean-data` topic.
3. SQL Error mesage Kafka `raw-data-dlq` topic.

### 4. Monitoring

Access Grafana dashboards at `http://localhost:3000` to monitor:
- Flink Cluster
- Kafka Cluster


### Configuration Files

- Flink configuration: `config/flink/jobmanager/config.yaml` and `config/flink/taskmanager/config.yaml`
- Kafka configuration: `config/kafka/kafka{1,2,3}/server.properties`
- Monitoring: `config/prometheus/prometheus.yaml` and `config/grafana/*`

## Deployment Notes

### Flink Configuration

⚠️ **Flink 1.20.0 specifics:**
- Flink 1.20.0 and 2.0.0 use `config.yaml` instead of `flink-conf.yaml`
- Only RocksDB state backend is supported

⚠️ **Docker Network:**
- If you want to change docker network name and sub ipv4, you make unsure to change correctly all configuration setting.

## Documentation Links

- [Apache Flink SQL Client Documentation](https://nightlies.apache.org/flink/flink-docs-master/docs/dev/table/sqlclient/)
- [Apache Flink Class Loader Documantation](https://nightlies.apache.org/flink/flink-docs-master/docs/ops/debugging/debugging_classloading/)
- [Apache Flink Configuration Options](https://nightlies.apache.org/flink/flink-docs-master/docs/deployment/config/)
- [Apache Flink Offical Streaming Proje Example](https://flink.apache.org/2020/07/28/flink-sql-demo-building-an-end-to-end-streaming-application/#preparation)
- [Apache Flink Kafka Documantation](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/table/kafka/)
- [Apache Kafka Client and Configuration Documantation](https://kafka.apache.org/documentation/#configuration)
- [Apache Kafka DQL Dead Letter Queue](https://www.kai-waehner.de/blog/2022/05/30/error-handling-via-dead-letter-queue-in-apache-kafka/)
- [Apache Flink Connector's Data Format](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/table/formats/overview/)