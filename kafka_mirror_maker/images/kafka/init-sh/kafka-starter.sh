#!/bin/bash
set -e

export KAFKA_HEAP_OPTS="-Xms2g -Xmx6g -XX:+ExitOnOutOfMemoryError"

cluster_id_a="AP6hyiddQNW5FPrAvR9kWw"
cluster_id_b="BP6hyiddQNW5FPrAvR9kWw"

current_hostname=$(hostname)

if [[ "$current_hostname" == "kafka1-a" ]]; then
  echo ""
  echo "Exporting the cluster ID" 
  echo ""
  cluster_id=$cluster_id_a
elif [[ "$current_hostname" == "kafka2-a" ]]; then
  echo ""
  echo "Exporting the cluster ID" 
  echo ""
  cluster_id=$cluster_id_a
elif [[ "$current_hostname" == "kafka3-a" ]]; then
  echo ""
  echo "Exporting the cluster ID" 
  echo ""
  cluster_id=$cluster_id_a
elif [[ "$current_hostname" == "kafka1-b" ]]; then
  echo ""
  echo "Exporting the cluster ID" 
  echo ""
  cluster_id=$cluster_id_b
elif [[ "$current_hostname" == "kafka2-b" ]]; then
  echo ""
  echo "Exporting the cluster ID" 
  echo ""
  cluster_id=$cluster_id_b
elif [[ "$current_hostname" == "kafka3-b" ]]; then
  echo ""
  echo "Exporting the cluster ID" 
  echo ""
  cluster_id=$cluster_id_b
fi

echo ""
echo "Formatting the log path." 
echo ""
${KAFKA_HOME}/bin/kafka-storage.sh format --config ${KAFKA_HOME}/config/server.properties --cluster-id $cluster_id --ignore-formatted
echo ""
echo "Starting the kafka broker." 
echo ""
${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties &

sleep 5

if [ $current_hostname == "kafka1-a" ]; then
  echo ""
  echo "Creating kafka topics."
  echo ""
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka1-a:9092,kafka2-a:9092,kafka3-a:9092 --topic topic-a --create --partitions 12 --replication-factor 3 &
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka1-a:9092,kafka2-a:9092,kafka3-a:9092 --topic topic-b --create --partitions 24 --replication-factor 3 &
fi

if [[ "$current_hostname" == "kafka1-a" ]]; then
  kafka-export-starter.sh &
elif [[ "$current_hostname" == "kafka1-b" ]]; then
  kafka-export-starter.sh &
fi

tail -f /opt/kafka/logs/server.log