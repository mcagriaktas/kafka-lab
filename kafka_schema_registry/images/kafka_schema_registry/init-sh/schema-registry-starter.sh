#!/bin/bash
set -e 

echo "Waiting for Kafka to be ready..."
sleep 10

echo "Starting Schema Registry..."
${SCHEMA_REGISTRY_HOME}/bin/schema-registry-start ${SCHEMA_REGISTRY_HOME}/etc/schema-registry/kafka_schema_registry.properties