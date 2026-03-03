#!/bin/bash

HOSTNAME=$(hostname)

# Build dynamic KAFKA_OPTS using hostname
export KAFKA_OPTS="${KAFKA_OPTS_STATIC} -Djavax.net.ssl.trustStore=/opt/kafka/config/jks/${HOSTNAME}.truststore.jks"

# (docker exec)
sed -i '/# KAFKA_ENV_START/,/# KAFKA_ENV_END/d' /etc/bash.bashrc
cat >> /etc/bash.bashrc <<EOF
# KAFKA_ENV_START
export KAFKA_OPTS="${KAFKA_OPTS}"
export KAFKA_HEAP_OPTS="${KAFKA_HEAP_OPTS}"
# KAFKA_ENV_END
EOF

{
  echo "KAFKA_OPTS=${KAFKA_OPTS}"
  echo "KAFKA_HEAP_OPTS=${KAFKA_HEAP_OPTS}"
} > /etc/environment

echo "Waiting for Keycloak..."
while ! curl -kf https://keycloak.dahbest.kfn:8443/realms/master > /dev/null 2>&1; do
  echo "Keycloak not ready yet. Sleeping for 2 seconds..."
  sleep 2
done
echo "Keycloak is ready."

echo "Controller starter script is running..."

# Bootstrap storage if needed
if [[ ! -f /opt/data/metadata/metadata.properties ]]; then
    /opt/kafka/bin/kafka-storage.sh format \
        --config /opt/kafka/config/controller.properties \
        --cluster-id a96i_0NbQrqSDy33dP9U7Q \
        --ignore-formatted
fi

sleep 20

/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/controller.properties
