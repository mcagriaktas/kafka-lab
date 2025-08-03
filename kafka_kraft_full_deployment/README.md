# Kafka KRaft Full Deployment
This project provides a fully configured deployment of a Kafka cluster using the KRaft (Kafka Raft) mode with a three-broker setup. The environment includes a variety of tools for monitoring and managing your Kafka cluster, making it easy to explore and operate a production-like setup locally.

 - Kafka UI (Provectus): Easily access and manage your Kafka cluster through a web interface at localhost:8080. Here, you can view topics, consumer groups, messages, and other cluster resources.
 - Prometheus UI: Monitor detailed Kafka broker metrics via Prometheus, available at localhost:9090. Metrics are collected from each broker through dedicated JMX exporters running on ports 7071, 7072, and 7073.
 - Grafana: Visualize and analyze your Kafka metrics in real time with pre-built dashboards in Grafana, accessible at localhost:3000.

All Kafka configuration files, including *.properties and *.yml files, are organized within the config folder for easy reference and customization. This setup is ideal for testing, learning, and managing Kafka with modern observability and UI tools in a local or development environment.

## Architecture Overview

This setup includes:
- **3 Kafka Brokers** running in KRaft mode
- **Kafka UI (Provectus)** for cluster management
- **Prometheus** for metrics collection
- **Grafana** for visualization
- **Jenkins** for CI/CD automation
- **Schema Registry** for schema management
- **Burrow** for consumer lag monitoring

## Access Points

| Service | URL | Port |
|---------|-----|------|
| Kafka UI (Provectus) | http://localhost:8080 | 8080 |
| Prometheus | http://localhost:9090 | 9090 |
| Grafana | http://localhost:3000 | 3000 |
| Jenkins | http://localhost:8081 | 8081 (internal) to 8085 (external) |
| Schema Registry | http://localhost:8082 | 8082 |
| Kafka Brokers | kafka{1,2,3}:9092,9092,9092 | 19092, 29092, 39092 |
| JMX Exporters | 7071 | 7071, 7072, 7073 |

---

## Grafana Monitoring

### Add Prometheus as a data source in Grafana:

1. Login to Grafana (localhost:3000)
2. Click on the hamburger menu icon (☰) in the left sidebar
3. Go to "Connections" -> "Data sources"
4. Click "Add data source"
5. Search and select "Prometheus"
6. Set the URL to http://prometheus:9090
7. Click "Save & test" at the bottom

### Create Dashboard:

![](screenshoots/kafka-grafana.png)
