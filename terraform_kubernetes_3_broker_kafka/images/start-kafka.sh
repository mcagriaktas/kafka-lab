#!/bin/bash

# Replace environment variables in server.properties
sed -i "s/\${node_id}/$node_id/g" /kafka/config/server.properties
sed -i "s/\${hostname}/$hostname/g" /kafka/config/server.properties
sed -i "s/\${EXTERNAL_PORT}/${EXTERNAL_PORT:-19092}/g" /kafka/config/server.properties

# Replace the controller.quorum.voters with the cluster members
if [ ! -z "$KAFKA_CLUSTER_MEMBERS" ]; then
    sed -i "s/controller.quorum.voters=.*$/controller.quorum.voters=$KAFKA_CLUSTER_MEMBERS/" /kafka/config/server.properties
fi

# Format kafka storage if needed
/kafka/bin/kafka-storage.sh format --config /kafka/config/server.properties --cluster-id 'EP6hyiddQNW5FPrAvR9kWw' --ignore-formatted

# Start Kafka
exec /kafka/bin/kafka-server-start.sh /kafka/config/server.properties