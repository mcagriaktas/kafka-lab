#!/bin/bash

if [ $(hostname) == "zookeeper1" ]; then
    echo "Formating logs path for Zookeeper on zookeeper1"
    mkdir -p /mnt/data/zookeeper_data && echo "1" > /mnt/data/zookeeper_data/myid
    sleep 2
    echo "Starting Zookeeper on zookeeper1"
    /mnt/apache-zookeeper-3.7.2-bin/bin/zkServer.sh --config /mnt/properties start
    tail -f /dev/null
elif [ $(hostname) == "zookeeper2" ]; then
    echo "Formating logs path for Zookeeper on zookeeper2"
    mkdir -p /mnt/data/zookeeper_data && echo "2" > /mnt/data/zookeeper_data/myid
    sleep 2
    echo "Starting Zookeeper on zookeeper2"
    /mnt/apache-zookeeper-3.7.2-bin/bin/zkServer.sh --config /mnt/properties start
    tail -f /dev/null
elif [ $(hostname) == "zookeeper3" ]; then
    echo "Formating logs path for Zookeeper on zookeeper3"
    mkdir -p /mnt/data/zookeeper_data && echo "3" > /mnt/data/zookeeper_data/myid
    sleep 2
    echo "Starting Zookeeper on zookeeper3"
    /mnt/apache-zookeeper-3.7.2-bin/bin/zkServer.sh --config /mnt/properties start
    tail -f /dev/null
fi