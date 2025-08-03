#!/bin/bash
set -e

echo "Starting Kafka Connect..."

${KAFKA_HOME}/bin/connect-distributed.sh ${KAFKA_HOME}/config/connect-distributed.properties