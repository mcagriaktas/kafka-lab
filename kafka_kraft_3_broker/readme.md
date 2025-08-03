# Kafka KRaft Fast 3 Broker Deployment
In this setup, you’ll run a **3-broker Kafka cluster** in KRaft mode.  
- The [Kafka UI (Provectus)](http://localhost:8080) is available for topic/cluster management.  
- All configuration files (`*.properties` and `*.yml`) are in the `config` folder.

> **Note:** This deployment makes it easy to spin up and manage a multi-broker Kafka cluster for development or testing.

---

### **Start all services:**
```bash
docker-compose up -d --build
```

### Create Basic Topic with Kafka UI (Provectus):

- Open `http://localhost:8080`
- Click **Create Topic**
- Set **Number of Partitions** = 3
- Set **Replication Factor** = 3

![](screenshoots/partitions.png)