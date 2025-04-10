#!/bin/bash

# Format kafka storage if needed
/opt/kafka/bin/kafka-storage.sh format --config /opt/kafka/config/server.properties --cluster-id 'EP6hyiddQNW5FPrAvR9kWw' --ignore-formatted

# Start Kafka with the configured JMX Exporter
exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties