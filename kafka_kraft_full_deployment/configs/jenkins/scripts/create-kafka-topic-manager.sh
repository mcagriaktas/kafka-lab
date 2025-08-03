#!/bin/bash
set -e

OPERATION="$1"
TOPIC_NAME="$2"
PARTITIONS="$3"
REPLICATION_FACTOR="$4"

BROKERS="kafka1:9092,kafka2:9092,kafka3:9092"

if [[ "$OPERATION" != "list" && -z "$TOPIC_NAME" ]]; then
  echo "Topic name is required for $OPERATION operation"
  exit 1
fi

if [[ "$OPERATION" == "delete" || "$OPERATION" == "alter" ]]; then
  topicExists=$( /opt/kafka/bin/kafka-topics.sh --bootstrap-server "$BROKERS" --list | grep -w "^${TOPIC_NAME}$" || true )
  if [[ -z "$topicExists" && "$OPERATION" == "delete" ]]; then
    echo "Topic $TOPIC_NAME does not exist. Skipping delete."
    exit 0
  fi
  if [[ -z "$topicExists" && "$OPERATION" == "alter" ]]; then
    echo "Cannot alter topic $TOPIC_NAME because it does not exist."
    exit 1
  fi
fi

case "$OPERATION" in
  create)
    CMD="/opt/kafka/bin/kafka-topics.sh --bootstrap-server $BROKERS --topic $TOPIC_NAME --create --partitions $PARTITIONS --replication-factor $REPLICATION_FACTOR"
    ;;
  delete)
    CMD="/opt/kafka/bin/kafka-topics.sh --bootstrap-server $BROKERS --topic $TOPIC_NAME --delete"
    ;;
  describe)
    CMD="/opt/kafka/bin/kafka-topics.sh --bootstrap-server $BROKERS --topic $TOPIC_NAME --describe"
    ;;
  list)
    CMD="/opt/kafka/bin/kafka-topics.sh --bootstrap-server $BROKERS --list"
    ;;
  alter)
    CMD="/opt/kafka/bin/kafka-topics.sh --bootstrap-server $BROKERS --topic $TOPIC_NAME --alter --partitions $PARTITIONS"
    ;;
  *)
    echo "Unknown operation: $OPERATION"
    exit 2
    ;;
esac

echo "Executing: $CMD"
eval $CMD

if [[ "$OPERATION" == "create" || "$OPERATION" == "alter" ]]; then
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server "$BROKERS" --topic "$TOPIC_NAME" --describe
fi
