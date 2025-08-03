# Kafka SASL_PLAINTEXT Deployment (KRaft Mode)

This repository delivers a production-ready deployment of Kafka 4.0.0 running in KRaft (Kafka Raft Metadata) mode with SASL_PLAINTEXT authentication configured using the PLAIN mechanism. This setup is designed to secure communication between Kafka clients and brokers, ensuring that only authenticated users can access your Kafka cluster.

The configuration reflects Kafka’s current limitations: the controller quorum in KRaft mode does not support SCRAM authentication. Therefore, this deployment uses the PLAIN mechanism for SASL-based authentication, which is fully supported for client-broker communication.

All necessary configuration files and example settings are provided, allowing you to quickly deploy and test a secure, production-grade Kafka environment leveraging KRaft mode and modern authentication strategies.

---

## Key Features

- ✅ **Kafka 4.0.0** in pure KRaft mode
- ✅ TLS encryption for internal and client communications
- ✅ 3-broker cluster with **automatic PLAIN user provisioning**
- ✅ Kafka UI (Provectus) with PLAIN integration
- ✅ Python data generator for testing (producer/consumer)

---

## Directory Structure

```bash
scram_kafka/
├── configs/
│   ├── kafka/
│   │   ├── broker1/      # Broker 1 config (PLAIN enabled)
│   │   ├── broker2/      # Broker 2 config (PLAIN enabled)
│   │   ├── broker3/      # Broker 3 config (PLAIN enabled)
│   │   ├── controller1/  # Controller 1 config (LAIN enabled)
│   │   ├── controller2/
│   │   └── controller3/
│   └── provectus/
├── data_generator/
│   ├── producer.py       # PLAIN-authenticated producer
│   └── consumer.py       # PLAIN-authenticated consumer
├── docker-compose.yml
├── images/
│   └── kafka/
│       ├── broker/
│       └── controller/
└── logs/
```

---

## Getting Started

---

1. **Start the Cluster:**
    ```bash
    docker compose up -d
    ```

2. **Test Data Generator:**
    > Producer and consumer users are **created automatically** when the container starts!

    ```bash
    python3 data_generator/producer.py
    python3 data_generator/consumer.py
    ```

3. **Access Kafka UI:**

    - [http://localhost:8080](http://localhost:8080)

**Credentials:**

| Role      | Username          | Password    | Notes                      |
|-----------|-------------------|------------|----------------------------|
| Admin     | kafka             | cagri3541  | For Kafka UI               |
| Producer  | client-producer   | cagri3541  | For test client            |
| Consumer  | client-consumer   | cagri3541  | Consumer group: `client-consumer` |

---