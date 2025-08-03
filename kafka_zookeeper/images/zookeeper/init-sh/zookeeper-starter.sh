#!/bin/bash
set -e

HOSTNAME=$(hostname)

echo "Starting Zookeeper on $HOSTNAME"

ZOOKEEPER_HOME=${ZOOKEEPER_HOME}
ZOOKEEPER_DATA_HOME=${ZOOKEEPER_DATA_HOME}
ZOO_CFG=${ZOOKEEPER_HOME}/conf

# Set myid based on hostname
case "$HOSTNAME" in
    zookeeper1)
        MYID=1
        ;;
    zookeeper2)
        MYID=2
        ;;
    zookeeper3)
        MYID=3
        ;;
    *)
        echo "Unknown hostname: $HOSTNAME. Must be zookeeper1, zookeeper2, or zookeeper3."
        exit 1
        ;;
esac

# Write myid
echo "$MYID" > "$ZOOKEEPER_DATA_HOME/myid"
echo "Wrote myid = $MYID to $ZOOKEEPER_DATA_HOME/myid"

# Start ZooKeeper
echo "Starting ZooKeeper with config: $ZOO_CFG"
$ZOOKEEPER_HOME/bin/zkServer.sh --config $ZOO_CFG start-foreground