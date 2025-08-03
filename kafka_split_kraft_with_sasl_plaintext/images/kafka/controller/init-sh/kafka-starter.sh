#!/bin/bash

export KAFKA_OPTS="-Djava.security.auth.login.config=/opt/kafka/config/controller_server_jaas.conf"
export KAFKA_HEAP_OPTS="-Xms2g -Xmx8g -XX:+ExitOnOutOfMemoryError"

echo "KAFKA_OPTS for controller: $KAFKA_OPTS"

${KAFKA_HOME}/bin/kafka-storage.sh format \
    --config ${KAFKA_HOME}/config/controller.properties \
    --cluster-id 'EP6hyiddQNW5FPrAvR9kWw' \
    --ignore-formatted


${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/controller.properties