# Kafka Cluster with Terraform

This project provides a Terraform infrastructure for deploying a scalable Apache Kafka cluster on Kubernetes.

## Overview

- Multi-broker Kafka cluster deployment
- Kubernetes-native configuration
- Terraform-managed infrastructure
- Configurable external access ports
- Built-in replication and fault tolerance

## Prerequisites

- Kubernetes cluster running
- Terraform installed (v1.0 or later)
- kubectl configured with cluster access
- Python and pip (for sample scripts)
  
<img width="1024" alt="pods-producer-consumer" src="https://github.com/user-attachments/assets/6c075c57-bbac-412a-9a1a-8016aac49f42" />

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/mcagriaktas/kafka-docker-setup.git
cd kafka-docker-setup
```

2. Deploy the cluster:
```bash
cd terraform
terraform init
terraform apply
```

## Configuration

### Variables

Key variables that can be modified in `variables.tf`:

```hcl
# Namespace configuration
variable "kubernetes_namespace" {
    description = "The namespace to deploy the application"
    type        = string
    default     = "kafka"
}

# External ports configuration
variable "broker_ports" {
    description = "External ports for each broker"
    type        = map(number)
    default     = {
        broker0 = 19092
        broker1 = 29092
        broker2 = 39092
    }
}
```

### Docker Image

The Kafka broker image is available on Docker Hub:
```
mucagriaktas/kafka:3.8.0
```

## Accessing the Cluster

The Kafka brokers are accessible at:
- Broker 0: `localhost:19092`
- Broker 1: `localhost:29092`
- Broker 2: `localhost:39092`

## Testing

1. Create a test topic:
```bash
kubectl exec -it kafka-0-0 -n kafka -- \
    kafka-topics.sh --create \
    --topic test \
    --bootstrap-server localhost:9092 \
    --partitions 3 \
    --replication-factor 3
```

2. List topics:
```bash
kubectl exec -it kafka-0-0 -n kafka -- \
    kafka-topics.sh --list \
    --bootstrap-server localhost:9092
```

3. Run the included sample scripts:
```bash
# Start consumer
python scripts/consumer.py

# In another terminal
python scripts/producer.py
```

## Cleanup

To remove the entire Kafka cluster:
```bash
terraform destroy
```

## Structure

```
.
├── terraform/
│   ├── main.tf          # Main Terraform configuration
│   ├── variables.tf     # Variable definitions
│   ├── provider.tf      # Provider configuration
│   └── outputs.tf       # Output definitions
├── scripts/
│   ├── consumer.py      # Sample consumer script
│   └── producer.py      # Sample producer script
└── README.md
```
