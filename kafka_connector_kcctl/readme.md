# Kafka-Connector Couchbase Sink Example

This repository provides a practical, hands-on example of integrating Apache Kafka with Couchbase by using the official Kafka Connect Couchbase Sink Connector. The project demonstrates how to configure and manage the connector both through the Kafka Connect REST API and with the command-line tool kcctl.

With this example, you will learn how to stream data from Kafka topics directly into a Couchbase database, leveraging the power of Kafka Connect for real-time data movement. The setup covers connector deployment, configuration steps, and management tasks, showing how to interact with the connector programmatically (via REST) as well as from the terminal (using kcctl).

Whether you are new to Kafka Connect or looking for a reference on integrating Couchbase as a sink, this repository provides a clear, working sample that can be adapted to your own use cases. It is ideal for those who want to automate and monitor the data pipeline between Kafka and Couchbase using widely adopted tools and best practices.

This repository demonstrates:
- Setting up a multi-node Kafka environment with Kafka Connect and Couchbase.
- Managing connectors using REST API and `kcctl` for DevOps automation and CI/CD.
- End-to-end data flow from Kafka topics to Couchbase buckets.

---

## 📁 Project Structure

```
.
├── configs/                     # All service configs (Kafka, Couchbase, Connect)
│   ├── kafka/                   # Kafka broker/server configs
│   ├── connect/                 # Kafka Connect & connector configs
│   └── couchbase/               # Couchbase bucket/user/init configs
├── data_generator/              # Scripts for producing test data to Kafka
├── docker-compose.yml           # Full stack orchestration
├── images/                      # Custom Dockerfiles for services (if any)
│   ├── kcctl/                   # Dockerized kcctl client
├── logs/                        # Logs from running services
└── README.md
```

---

## 🌐 Key Endpoints

| Service            | URL/Command                                  | Notes                                    |
|--------------------|----------------------------------------------|------------------------------------------|
| **Couchbase UI**   | [http://localhost:8091](http://localhost:8091) | Login: `cagri` / `35413541`              |
| **Kafka UI**       | [http://localhost:8080](http://localhost:8080) | For topic and message monitoring         |
| **Kafka Connect**  | [http://localhost:8083](http://localhost:8083) | REST API for connector management        |
| **kcctl CLI**      | `docker exec -it kafka-kcctl ...`             | Manage connectors via CLI inside Docker  |

---

## 📊 What is Kafka Connect Couchbase Sink Connector?

The **Couchbase Sink Connector** is an official [Kafka Connect](https://kafka.apache.org/documentation/#connect) plugin that streams records from Kafka topics directly into Couchbase.  
- Supports custom document ID paths, collections, and bulk writes.
- Operates as a Kafka Connect "sink"—subscribing to topics and persisting data to Couchbase buckets.
- Enables scalable, fault-tolerant data integration.

**Main documentation:**  
- [Couchbase Kafka Connector](https://docs.couchbase.com/kafka-connector/current/index.html)

---

## 🛠 What is kcctl?

[`kcctl`](https://github.com/kcctl/kcctl) is a modern, user-friendly CLI for Kafka Connect, inspired by `kubectl`.  
- Allows you to **apply**, **list**, **describe**, and **delete** connectors with simple commands.
- More scriptable and CI/CD friendly than using raw REST API calls.

Example usage:
```bash
docker exec -it kafka-kcctl kcctl get connectors
docker exec -it kafka-kcctl kcctl describe connector couchbase-sink
```

---

## 📈 Monitoring

- **Kafka UI** (`localhost:8080`): Monitor topics, partitions, consumer lag.
- **Couchbase UI** (`localhost:8091`): View buckets, documents, stats.

---

## ⚡ Quick Start

1. **Start the stack:**
```bash
docker-compose up -d --build
```

2. **Initialize Couchbase cluster and bucket:**
```bash
# Initialize cluster (inside Couchbase container)
docker exec -it couchbase couchbase-cli cluster-init --cluster 172.80.0.60 --cluster-username cagri --cluster-password 35413541 --services=data,index,query --cluster-ramsize=512 --cluster-index-ramsize=256

# Create bucket
docker exec -it couchbase couchbase-cli bucket-create --cluster 172.80.0.60 --username cagri --password 35413541 --bucket cagri-bucket --bucket-type couchbase --bucket-ramsize 100 --bucket-replica 1 --bucket-eviction-policy valueOnly --enable-flush 1 --compression-mode passive
```

3. **Create Kafka topic:**
```bash
docker exec -it kafka1 /opt/kafka/bin/kafka-topics.sh --create --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --replication-factor 2 --partitions 3 --topic couchbase-topic
```

4. **Deploy Couchbase Sink Connector**

**Option A: Using REST API**
```bash
curl -X PUT http://localhost:8083/connectors/couchbase-sink/config        -H "Content-Type: application/json" -d '{
    "connector.class": "com.couchbase.connect.kafka.CouchbaseSinkConnector",
    "tasks.max": "1",
    "topics": "couchbase-topic",
    "couchbase.seed.nodes": "172.80.0.60",
    "couchbase.bucket": "cagri-bucket",
    "couchbase.username": "cagri",
    "couchbase.password": "35413541",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": false,
    "couchbase.document.id": "/id",
    "couchbase.collection": "_default._default"
}'
```

**Option B: Using kcctl**
```bash
docker exec -it kafka-kcctl /opt/kafka_kcctl/bin/kcctl apply -f /opt/kafka_kcctl/connector_json/couchbase_connector.json --name couchbase
```

5. **Produce example data:**
```bash
python data_generator/producer.py
```

6. **Verify results:** 

REST: 
```bash
curl -X GET http://localhost:8083/connectors/couchbase-sink/status
```

KCCTL:
```BASH
docker exec -it kafka-kcctl /opt/kafka_kcctl/bin/kcctl get connectors
```

**Couchbase bucket:**  
Open [http://localhost:8091](http://localhost:8091), check documents in `cagri-bucket`.

---

## 🛠️ Customization

**Change topics, bucket, or connector parameters:**  
Edit `configs/connect/couchbase_connector.json` (or modify REST payload as above).
**Add more brokers or connectors:**  
Adjust `docker-compose.yml` and relevant configs for scaling.

---

## 📝 Notes & Tips

- Both **REST API** and **kcctl** are supported—choose whichever fits your workflow.
- All service credentials, endpoints, and ports can be customized in the `docker-compose.yml` and config files.
- Check logs in `logs/` for debugging any issues with Kafka, Connect, or Couchbase.
- The included `data_generator/producer.py` can be adapted for different data schemas or Kafka topics.

---

## 📚 References

- [Couchbase Kafka Connector Docs](https://docs.couchbase.com/kafka-connector/current/index.html)
- [kcctl GitHub](https://github.com/kcctl/kcctl)
- [Kafka Connect Documentation](https://kafka.apache.org/documentation/#connect)
- [Couchbase Documentation](https://docs.couchbase.com/home/index.html)

---

