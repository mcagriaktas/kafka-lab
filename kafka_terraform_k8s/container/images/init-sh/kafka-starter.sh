#!/bin/bash
set -e

export KAFKA_OPTS="-Xms2g -Xmx6g -XX:MaxRAMPercentage=80.0 -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+ExitOnOutOfMemoryError"

# ====== Pod Index Extraction ======
if [[ -z "${pod_name}" ]]; then
  echo "pod_name env not set!"
  exit 1
fi
export POD_INDEX=$(echo "${pod_name}" | awk -F'-' '{print $NF}')
export node_id="${POD_INDEX}"

# ====== Dynamic Port ======
export external_port=$((19092 + POD_INDEX * 10000))

# ====== Hostname ======
export hostname="${pod_name}.kafka-headless.kafka.svc.cluster.local"

# ====== Replicas (number of brokers) ======
if [[ -z "${replicas}" ]]; then
  echo "replicas env not set!"
  exit 1
fi

# ====== Dynamically Generate controller_quorum_voters ======
export controller_quorum_voters=""
for i in $(seq 0 $((replicas-1))); do
  entry="${i}@kafka-${i}.kafka-headless.kafka.svc.cluster.local:9093"
  if [[ $i -ne 0 ]]; then
    controller_quorum_voters="${controller_quorum_voters},"
  fi
  controller_quorum_voters="${controller_quorum_voters}${entry}"
done

# ====== Substitute values in server.properties ======
sed -i "s|\${node_id}|${node_id}|g" ${KAFKA_HOME}/config/server.properties
sed -i "s|\${hostname}|${hostname}|g" ${KAFKA_HOME}/config/server.properties
sed -i "s|\${external_port}|${external_port}|g" ${KAFKA_HOME}/config/server.properties
sed -i "s|\${controller_quorum_voters}|${controller_quorum_voters}|g" ${KAFKA_HOME}/config/server.properties

# ====== Format Storage (ignore if already formatted) ======
${KAFKA_HOME}/bin/kafka-storage.sh format --config ${KAFKA_HOME}/config/server.properties --cluster-id ${cluster_id:-"EP6hyiddQNW5FPrAvR9kWw"} --ignore-formatted

echo "==== Rendered Config ===="
cat ${KAFKA_HOME}/config/server.properties
echo "========================="

echo "=== Waiting for Creating-Pod ==="
sleep 10
echo "================================"

exec ${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties
