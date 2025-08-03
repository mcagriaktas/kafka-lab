# Kafka SCRAM Deployment (KRaft Mode)

This repository provides a production-ready deployment of Apache Kafka 4.0.0 using the modern KRaft (Kafka Raft Metadata) mode with SCRAM-SHA-256 authentication enabled. The setup is designed for secure client-broker communication, ensuring that only authenticated users and applications can connect to your Kafka cluster.

The configuration follows Kafka’s current limitations, where controller authentication is not yet fully supported. As a result, this deployment focuses on securing the communication between Kafka brokers and clients using SCRAM-SHA-256, one of the recommended and widely adopted authentication mechanisms for Kafka.

With all necessary configuration files and example settings included, this repository offers a strong foundation for setting up a secure, production-grade Kafka environment leveraging the benefits of KRaft mode and modern authentication practices.

> **⚠️ Critical Warning**  
> *As of Kafka KRaft Version 4.0.0, the controller quorum does **not support SCRAM authentication** for internal communication. All SCRAM authentication in this repo is for client-broker security.*

---

## Key Features

- ✅ **Kafka 4.0.0** in pure KRaft mode
- ✅ **SCRAM-SHA-256 authentication** for client-broker communication
- ✅ **TLS encryption** for all internal and client channels
- ✅ Pre-configured **3-broker cluster** with auto SCRAM user provisioning
- ✅ Kafka UI (Provectus) integrated with SCRAM
- ✅ Python producer/consumer for validation
- ✅ Full JKS keystore management (ready-to-use)

---

## Why No Controller Authentication?

| Component      | SCRAM Support | Reason                                                                 |
|----------------|---------------|------------------------------------------------------------------------|
| **Brokers**    | ✅ Supported  | Client authentication (producers/consumers)                            |
| **Controller** | ❌ Not Supported | Kafka 4.0.0 controller quorum **cannot use SCRAM** for metadata communication |
| **Deployment** | Brokers ONLY  | Brokers are secured, controllers use default (no SCRAM)                |

> This architecture secures the broker endpoints — the attack surface for clients — while acknowledging the controller limitation.

---

## Directory Structure

```bash
scram_kafka/
├── configs/
│   ├── kafka/
│   │   ├── broker1/
│   │   ├── broker2/
│   │   └── broker3/
│   └── provectus/
├── data_generator/
│   ├── producer.py
│   └── consumer.py
├── docker-compose.yml
├── images/
│   └── kafka/
│       └── broker/
├── jks_key_generator/
│   ├── jks_generator.sh
│   └── keys/
└── logs/
```

---

## Getting Started

---

1. **Create Docker Network:**
    ```bash
    docker network create --subnet=172.80.0.0/16 dahbest
    ```

2. **Start the Cluster:**
    ```bash
    docker compose up -d
    ```

3. **Test Data Generator:**
    > Producer and consumer users are **created automatically** on broker start.

    ```bash
    python3 data_generator/producer.py
    python3 data_generator/consumer.py
    ```

4. **Access Kafka UI:**

    - [http://localhost:8080](http://localhost:8080)

**Credentials:**

| Role      | Username          | Password    | Notes             |
|-----------|-------------------|------------|-------------------|
| Admin     | kafka             | cagri3541  | For Kafka UI      |
| Producer  | client-producer   | cagri3541  | For test client   |
| Consumer  | client-consumer   | cagri3541  | Consumer group: `client-consumer` |

---

## Security Configuration

### SCRAM Authentication Flow

```text
Client → Broker: CONNECT (SCRAM-SHA-256)
Broker → Client: Send nonce
Client → Broker: Send proof + credentials
Broker → Client: Auth success
Client ↔ Broker: Produce/Consume messages
```

### Key Security Components

| Component       | Location                                 | Purpose                       |
|-----------------|------------------------------------------|-------------------------------|
| JAAS Config     | `configs/kafka/broker*/broker_server_jaas.conf` | SCRAM user/pass definition    |
| Keystores       | `configs/kafka/broker*/jks/`             | TLS certs (broker identity)   |
| Truststores     | `configs/kafka/broker*/jks/`             | CA root certs                 |
| Admin Client    | `configs/kafka/broker*/admin_client.conf` | Broker-to-broker config       |

> All passwords are stored hashed in JAAS SCRAM configs.

---

## Customization

### Generate JKS Keys (Already Included)

To regenerate all keystores if needed:
```bash
cd jks_key_generator
./jks_generator.sh
```

---

## Troubleshooting

| Symptom                        | Solution                                      |
|--------------------------------|-----------------------------------------------|
| `SASL authentication failed`   | Check JAAS configs vs. `admin_client.conf`    |
| `Connection reset`             | Verify keystore/truststore with keytool       |
| `No SCRAM credentials`         | Check logs for user creation messages         |
| `Kafka UI connection failed`   | Ensure UI SCRAM credentials are correct       |

**Log Inspection**
```bash
docker compose logs broker1
```

---