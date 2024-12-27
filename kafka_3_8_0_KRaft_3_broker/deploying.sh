#!/bin/bash

# Create necessary directories
mkdir -p data_logs/grafana_data
mkdir -p data_logs/kafka_data
mkdir -p data_logs/prometheus_data

# Set permissions
docker-compose up -d --build

sleep 10

docker-compose down

sleep 2

sudo chown -R 777 -R data_logs
