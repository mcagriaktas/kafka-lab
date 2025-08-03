# Apache Kafka CRUISE-CONTROL and CRUISE-CONTROL-UI

This repository provides a Docker-based environment for experimenting with Apache Kafka, Cruise Control, and the Cruise Control UI. With this stack, you can easily deploy a local Kafka cluster and take advantage of Cruise Control’s real-time monitoring, intelligent load balancing, and automated cluster management features.

Cruise Control automatically gathers snapshots of your Kafka cluster and begins training its internal optimization model as soon as the stack starts. Once initialized, it continuously monitors your Kafka environment, analyzing cluster metrics and workload patterns. Using the goals defined in the cruisecontrol.properties file, Cruise Control evaluates cluster health and makes optimization decisions, rebalancing partitions and resources to maximize performance and ensure efficient resource utilization.

The Cruise Control UI provides an intuitive web interface for visualizing the cluster’s status, tracking ongoing rebalancing operations, and managing optimization proposals in real time. This setup is ideal for anyone looking to explore advanced Kafka operations, automate routine cluster maintenance, or better understand how Cruise Control can be used to keep Kafka running smoothly and efficiently.

---

## 📁 Project Structure

```
.
├── configs/                  
│   ├── cruise-control/       # Cruise Control configs (capacity, broker sets, properties)
│   ├── cruise-control-ui/    # UI configs (CSV clusters, app conf)
│   └── kafka/                # Kafka broker configs
├── data_generator/           # Scala-based producer for test data
│   ├── jars/                 # Kafka client JARs
│   └── producer.scala        # Simple Scala producer script
├── images/                   # Custom Docker images
│   ├── cruise-control/
│   ├── cruise-control-ui/
│   └── kafka/
├── docker-compose.yml        # Multi-container orchestration
├── logs/                     # Mount point for log output
└── README.md
```

---

## 🌐 Key Endpoints

| Service                | URL                                                | Notes                                |
|------------------------|----------------------------------------------------|--------------------------------------|
| **Cruise Control UI**  | [http://localhost:8090](http://localhost:8090)     | Visualize and operate the cluster    |
| **Cruise Control API** | [http://localhost:9090/kafkacruisecontrol/](http://localhost:9090/kafkacruisecontrol/) | REST API for status, proposals, etc. |

**Test API:**  
```bash
curl "http://localhost:9090/kafkacruisecontrol/state"
```

---

## 📊 What is Cruise Control?

[Apache Kafka Cruise Control](https://github.com/linkedin/cruise-control) is an open-source tool that continuously monitors, analyzes, and automatically optimizes resource utilization in Kafka clusters:
- Collects cluster metrics, evaluates health, and suggests or applies rebalancing proposals.
- Balances broker loads for disk, network, and CPU to maintain stability and efficiency.
- Provides a REST API for cluster state, rebalance proposals, and operational controls.

**Optimization is guided by goals in `cruisecontrol.properties`:**
- `default.goals`: Used when none specified in a request.
- `goals`: General balancing goals.
- `intra.broker.goals`: Data balancing within a broker.
- `hard.goals`: Must always be satisfied for any optimization.

---

## 📊 What is Cruise Control UI?

[**Cruise Control UI**](https://github.com/linkedin/cruise-control-ui) is a web-based frontend for managing and visualizing Kafka Cruise Control operations.  
- Connects to Cruise Control REST API.
- Shows broker utilization, partition distribution, and rebalance proposals.
- Supports admin actions (move partitions, fix replicas) directly from the interface.

**Configured by:**
- `configs/cruise-control-ui/config.csv`: Defines clusters in the UI (name, API URL)
- `cruise-control-ui.conf`: Play Framework backend settings

---

## 📈 UI Features

Visit [http://localhost:8090](http://localhost:8090) to:

- 🔍 **Cluster Overview:** Broker CPU, disk, network usage
- 📊 **Partition Distribution:** Balance of topic partitions across brokers
- 🔄 **Rebalance Proposals:** View, approve, and execute optimization suggestions
- 🛠️ **Admin Actions:** Move partitions, fix offline replicas
- 🕓 **Load History:** Visualize load/traffic trends

**Note:** After startup, you may see a warning about snapshot range (`There is no window available...`). This means Cruise Control is still collecting metrics—optimization will begin automatically once enough data is gathered (usually 2–5 minutes).

---

## ⚡ Quick Start

1. **Start the stack:**
   ```bash
   docker-compose up -d
   ```

2. **Wait for Cruise Control to collect enough Kafka metrics** (about 2–5 minutes after all services are up).

3. **Access the UI:**  
   Open [http://localhost:8090](http://localhost:8090) to monitor and interact with your cluster.

4. **Test API endpoints:**  
   Example:
   ```bash
   curl "http://localhost:9090/kafkacruisecontrol/state"
   ```

---

## 🛠️ Customization

- **Modify optimization goals, metrics, or detection intervals:**  
  Edit `configs/cruise-control/cruisecontrol.properties`
- **Adjust hardware specs or broker sets:**  
  Update `capacity.json`, `brokerSets.json` in `configs/cruise-control/`
- **Change UI settings:**  
  Edit `configs/cruise-control-ui/config.csv` or `cruise-control-ui.conf`
- **Simulate load:**  
  Use `data_generator/producer.scala` to produce uneven loads and test rebalance behavior.

---

## 📝 Notes & Tips

- ⏳ **Startup Delay:** Cruise Control waits to gather cluster metrics before generating proposals.
- 💾 **Capacity Settings:** Make sure `capacity.json` matches your broker/container specs—misconfiguration may prevent rebalancing.
- 🛑 **Warnings in UI:** Initial window errors are expected and will resolve as Cruise Control finishes data collection.

---

## 📚 References

- [Cruise Control GitHub](https://github.com/linkedin/cruise-control)
- [Cruise Control UI GitHub](https://github.com/linkedin/cruise-control-ui)
- [Kafka Official Documentation](https://kafka.apache.org/documentation/)
- [Running Cruise Control without ZooKeeper](https://github.com/linkedin/cruise-control/wiki/Run-without-ZooKeeper)
- [Kafka Summit Cruise Control Intro](https://www.confluent.io/events/kafka-summit-london-2023/an-introduction-to-kafka-cruise-control/)

---

## 🤝 Contributing

Feel free to fork, improve, and submit pull requests.  
Ideas welcome for:
- TLS/SASL support
- Dynamic broker scaling
- Enhanced data generation for testing

---