#!/bin/bash

sleep 10

echo ""

echo "kafka admin user creating."
/opt/kafka/bin/kafka-configs.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --command-config /opt/kafka/config/admin_client.conf \
    --alter \
    --add-config "SCRAM-SHA-256=[password=cagri3541]" \
    --entity-type users \
    --entity-name "kafka"

echo ""

echo "kafka admin's ACLS adding."
/opt/kafka/bin/kafka-acls.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --command-config /opt/kafka/config/admin_client.conf \
    --add \
    --allow-principal "User:kafka" \
    --operation All \
    --topic '*' \
    --group '*' \
    --cluster

echo ""

echo "kafka-ui user creating."
/opt/kafka/bin/kafka-configs.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --command-config /opt/kafka/config/admin_client.conf \
    --alter \
    --add-config "SCRAM-SHA-256=[password=cagri3541]" \
    --entity-type users \
    --entity-name "kafkaui"

echo ""

echo "kafka-ui user's ACLS adding."
/opt/kafka/bin/kafka-acls.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --command-config /opt/kafka/config/admin_client.conf \
    --add \
    --allow-principal "User:kafkaui" \
    --operation All \
    --topic '*' \
    --group '*' \
    --cluster

echo ""

echo "test topic is creating for client"
/opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --create --topic cagri-topic \
    --partitions 3 --replication-factor 2 \
    --config min.insync.replicas=2 \
    --command-config /opt/kafka/config/admin_client.conf

echo ""

echo "client-producer user is creating"
/opt/kafka/bin/kafka-configs.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --command-config /opt/kafka/config/admin_client.conf \
    --alter \
    --add-config "SCRAM-SHA-256=[password=cagri3541]" \
    --entity-type users \
    --entity-name "client-producer"

echo ""

echo "client-producer's ACLS is adding"
/opt/kafka/bin/kafka-acls.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --command-config /opt/kafka/config/admin_client.conf \
    --add \
    --allow-principal "User:client-producer" \
    --operation WRITE \
    --topic 'cagri-topic'

echo ""

echo "client-consumer user is creating"
/opt/kafka/bin/kafka-configs.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --command-config /opt/kafka/config/admin_client.conf \
    --alter \
    --add-config "SCRAM-SHA-256=[password=cagri3541]" \
    --entity-type users \
    --entity-name "client-consumer"

echo ""

echo "client-consumer's ACLS is creating"
/opt/kafka/bin/kafka-acls.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --command-config /opt/kafka/config/admin_client.conf \
    --add \
    --allow-principal "User:client-consumer" \
    --operation READ \
    --topic 'cagri-topic'

echo ""

echo "client-consumer's Consumer Group ACLS is creating"
/opt/kafka/bin/kafka-acls.sh \
    --bootstrap-server broker1:9092,broker2:9092,broker3:9092 \
    --command-config /opt/kafka/config/admin_client.conf \
    --add \
    --allow-principal "User:client-consumer" \
    --operation READ \
    --group "client-consumer"

echo ""
