# Kafka Burrow - Consumer Lag Monitoring Stack

This project provides a complete Kafka observability stack featuring Burrow, Prometheus, and Grafana for monitoring Kafka consumer lag, consumer group health, and the overall status of your Kafka cluster in real time.

With this repository, you can easily set up a local, multi-broker Kafka environment designed for automated data generation and fully integrated consumer lag monitoring through LinkedIn Burrow. The setup also includes ready-to-use Grafana dashboards, allowing you to instantly visualize your streaming workloads and monitor key Kafka metrics.

Once deployed, you gain real-time insight into the flow of messages within your Kafka topics, enabling you to track how up-to-date your consumers are, detect issues with consumer group performance, and quickly identify any lag or health problems across your cluster. Burrow automatically analyzes consumer group status and reports on lag and health, while Prometheus collects and stores these metrics. Grafana then makes it easy to explore and visualize this data with intuitive dashboards.

In summary, this project enables you to launch a robust, local Kafka environment with multiple brokers, seamless data generation, and comprehensive, real-time monitoring of consumer lag and consumer group health—all in a single, professional solution.

---

## 📁 Project Structure

```
.
├── configs/                  # Configuration files for all services
│   ├── burrow/               # Burrow config (burrow.toml)
│   ├── grafana/              # Grafana dashboards & provisioning
│   ├── kafka/                # Kafka server.properties per broker
│   └── prometheus/           # Prometheus scraping rules
├── data_generator/           # Python/Scala-based producer for simulating real-time events
├── docker-compose.yml        # Orchestrates the entire observability stack
├── images/                   # Custom Docker images with init scripts
│   ├── burrow/
│   ├── grafana/
│   ├── kafka/
│   └── prometheus/
├── logs/                     # Mount point for service logs (runtime)
└── README.md
```

---

## 🌐 Key Endpoints

| Service       | URL                                       | Notes                                  |
|---------------|-------------------------------------------|----------------------------------------|
| **Grafana**   | [http://localhost:3000](http://localhost:3000)         | Login: `admin` / `3541`                |
| **Prometheus**| [http://localhost:9090](http://localhost:9090)         | Scrape targets & explore metrics       |
| **Burrow API**| [http://localhost:8000/v3/kafka](http://localhost:8000/v3/kafka) | Burrow REST API for consumer groups    |
| **Kafka**     | Internal: `kafka{1,2,3}:9092`, External: `localhost:19092,29092,39092` | Broker endpoints for producers/consumers |

---

## 📊 What is Burrow?

[Burrow](https://github.com/linkedin/Burrow) is LinkedIn’s open-source Kafka **consumer lag checking** and group health monitoring tool. It continuously inspects consumer offset lags and exposes detailed REST APIs and metrics, making it easy to automate alerting and dashboarding of Kafka consumer health.

**Main features in this stack:**

- **Real-time Lag Tracking:** See exactly how far behind each consumer group is, per topic/partition.
- **Group Status:** Burrow tracks if groups are `UP`, `DOWN`, or `REBALANCING`.
- **REST APIs:** Easily query all lag and status data programmatically.
- **Prometheus Integration:** Burrow metrics are exposed for scraping and visualization in Grafana.

**Key Burrow API Endpoints:**

- Consumer group status & lag:  
  `http://localhost:8000/v3/kafka/local/consumer/<group>`  
  Example:  
  [http://localhost:8000/v3/kafka/local/consumer/cagri-group](http://localhost:8000/v3/kafka/local/consumer/cagri-group)
- All metrics for Prometheus:  
  [http://localhost:8000/metrics](http://localhost:8000/metrics)
- Full API docs: [Burrow API v3](https://github.com/linkedin/Burrow/wiki/REST-API)

---

## 📈 Grafana Dashboard

Burrow metrics are visualized via an **auto-provisioned Grafana dashboard**:

- **Consumer Group Lag:** Message delay per group/topic/partition
- **Group Health Status:** Instantly see if your consumers are healthy
- **Lag Trends:** Analyze lag spikes or slow consumers over time

**Open Grafana:**  
[http://localhost:3000](http://localhost:3000)  
Default login: `admin` / `3541`  
Dashboard name: **Kafka Consumer Lag Overview**  
Datasource: **Prometheus**

_You can customize or extend this dashboard by editing `configs/grafana/datasource/kafka_dashboard.json`, or exporting updated dashboards from the Grafana UI._

---

## ⚡ Quick Start

1. **Start all services:**
    ```bash
    docker-compose up -d
    ```

2. **Open the dashboards:**
   - Grafana: [http://localhost:3000](http://localhost:3000)
   - Prometheus: [http://localhost:9090](http://localhost:9090)
   - Burrow API: [http://localhost:8000/v3/kafka](http://localhost:8000/v3/kafka)
     - Burrow API:
     ```bash

     ```
     
3. **Generate test data:**
   - The `data_generator/producer.py` script will automatically start and publish sample data into Kafka for live monitoring.
   - You can also run or modify it manually:
     ```bash
     python data_generator/producer.py
     ```
     (When the containers start, a cagri-group consumer automatically runs in the kafka1 container.)

---

## 🛠️ Customization

### Add Topics/Consumers

- Modify and run `data_generator/producer.py` to publish to different topics.
- Start your own consumers that join the default group (e.g. `cagri-group`) or create new groups.
- Burrow will **auto-discover** all active groups and begin monitoring them.

### Change Burrow Settings

- Edit `configs/burrow/burrow.toml` for cluster, broker, or lag checker changes.
- Full config options: [Burrow Configuration Docs](https://github.com/linkedin/Burrow/wiki/Configuration)

### Customize Grafana

- Edit or import dashboards as needed in `configs/grafana/datasource/kafka_dashboard.json`
- Export improved dashboards from Grafana UI → save them to your config folder for future runs.

---

## 📝 Notes & Tips

- **API Reference:** For all Burrow REST endpoints, see [http://localhost:8000/v3/kafka](http://localhost:8000/v3/kafka).
- **Metrics:** Prometheus scrapes Burrow at `/metrics`, which powers the Grafana panels.
- **Service Logs:** All container logs are mounted to the `logs/` folder for easy troubleshooting.
- **Cluster Config:** Supports multi-broker Kafka for realistic testing scenarios.

---

## 📚 References

- [LinkedIn Burrow on GitHub](https://github.com/linkedin/Burrow)
- [Burrow REST API](https://github.com/linkedin/Burrow/wiki/REST-API)
- [Kafka Official Documentation](https://kafka.apache.org/documentation/)
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)

---