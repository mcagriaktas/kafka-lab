#!/bin/bash

echo "Starting Kafka UI..."

sleep 30

java --add-opens java.rmi/javax.rmi.ssl=ALL-UNNAMED -Dspring.config.additional-location=/opt/config.yml -jar /opt/kafka-ui-api-v1.2.0.jar