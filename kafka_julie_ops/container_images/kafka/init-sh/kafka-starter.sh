#!/bin/bash
set -e

export KAFKA_HEAP_OPTS="-Xms4G -Xmx4G"

${KAFKA_HOME}/bin/kafka-storage.sh format --config ${KAFKA_HOME}/config/server.properties --cluster-id 'EP0hyiddQNW5FPrAvR9kWw' --ignore-formatted

exec ${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties