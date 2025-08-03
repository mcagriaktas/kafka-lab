# Kafka Monitoring with Prometheus JMX Exporter and Grafana

This guide shows how to monitor Kafka brokers using Prometheus JMX Exporter and visualize metrics in Grafana.

## Prerequisites
- Kafka cluster setup (For Kafka installation, check: [kafka-docker-setup](https://github.com/mcagriaktas/kafka-docker-setup))
- Docker and Docker Compose

## Setting up JMX Prometheus Agent

1. Install JMX Prometheus Agent on each Kafka broker:
```bash
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.19.0/jmx_prometheus_javaagent-0.19.0.jar -O /opt/jmx_exporter/jmx_prometheus_javaagent.jar
```

2. Configure Kafka to use JMX exporter:
```bash
export KAFKA_OPTS="-javaagent:/opt/jmx_exporter/jmx_prometheus_javaagent.jar=7071:/opt/jmx_exporter/kafka-metrics.yml"
```

3. Create kafka-metrics.yml with necessary metrics:
```yaml
lowercaseOutputName: true
lowercaseOutputLabelNames: true

rules:
  # Broker Metrics
  - pattern: kafka.server<type=app-info,id=(.+)>
    name: kafka_broker_status
    type: GAUGE
    labels:
      broker_id: "$1"

  # Consumer Lag Metrics
  - pattern: kafka.server:type=FetcherLagMetrics,name=ConsumerLag,clientId=([-.\w]+),topic=([-.\w]+),partition=([0-9]+)
    name: kafka_server_consumer_lag
    type: GAUGE
    labels:
      client_id: "$1"
      topic: "$2"
      partition: "$3"

  # Throughput Metrics
  - pattern: kafka.server<type=BrokerTopicMetrics,name=MessagesInPerSec,topic=(.+)><>OneMinuteRate
    name: kafka_server_topic_messages_in_rate
    type: GAUGE
    labels:
      topic: "$1"
```

## Prometheus Setup

1. Download and install Prometheus:
```bash
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
```

2. Configure prometheus.yml:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s

scrape_configs:
  - job_name: 'kafka'
    static_configs:
      - targets:
          - 'kafka1:7071'
          - 'kafka2:7071'
          - 'kafka3:7071'

  - job_name: 'prometheus'
    static_configs:
      - targets:
          - 'localhost:9090'
```

3. Start Prometheus:
```bash
exec ./prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus/data \
  --web.enable-lifecycle \
  --web.enable-admin-api
```

## Grafana Setup

1. Add Prometheus Data Source:
   - Navigate to Configuration → Data Sources
   - Add new Prometheus data source
   - Set Prometheus URL and test connection

2. Import Dashboard:
   - Go to Create → Import
   - Use provided JSON or create new dashboard

3. Useful Metrics to Monitor:
   - Broker Status: `up{job="kafka"}`
   - Consumer Lag: `sum(kafka_server_consumer_lag) by (client_id, topic)`
   - Messages per Second: `sum(increase(kafka_server_broker_metrics_count{metric_name="MessagesInPerSec"}[1m])) by (instance)`
   - Broker Log Size: `sum(kafka_log_size) by (instance)`

## More Information
For detailed metric configurations and dashboard examples, check the `my github repo` directory:
[grafana-example-dashboard](https://github.com/mcagriaktas/kafka-lab/tree/main/kafka_kraft_3_broker/config/grafana/datasource)