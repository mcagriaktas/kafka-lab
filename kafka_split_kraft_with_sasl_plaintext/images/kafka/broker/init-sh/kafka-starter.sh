#!/bin/bash

export KAFKA_OPTS="-Djava.security.auth.login.config=/opt/kafka/config/broker_server_jaas.conf"
export KAFKA_HEAP_OPTS="-Xms2g -Xmx8g -XX:+ExitOnOutOfMemoryError"

echo "KAFKA_OPTS for broker: $KAFKA_OPTS"

if [[ $(hostname) == "broker1" ]]; then
    echo "Running users-create-starter.sh..."
    users-create-starter.sh &
fi

${KAFKA_HOME}/bin/kafka-storage.sh format \
  --config "${KAFKA_HOME}/config/broker.properties" \
  --cluster-id 'EP6hyiddQNW5FPrAvR9kWw' \
  --ignore-formatted

sleep 2

${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/broker.properties