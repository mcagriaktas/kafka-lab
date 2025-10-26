#!/bin/bash

sleep 10

if [[ $HOSTNAME == "broker1" ]]; then
    while [ ! -f "/opt/kafka/config/keytabs/broker1.keytab" ]; do 
        echo "Waiting for broker1.keytab file..."
        sleep 1
    done
    echo "broker1.keytab file found"
    echo""
    echo "Starting kafka users creation script"
    kafka-starter-user-creator.sh &
elif [[ $HOSTNAME == "broker2" ]]; then
    while [ ! -f "/opt/kafka/config/keytabs/broker2.keytab" ]; do 
        echo "Waiting for broker2.keytab file..."
        sleep 1
    done
    echo "broker.keytab2 file found"
elif [[ $HOSTNAME == "broker3" ]]; then
    while [ ! -f "/opt/kafka/config/keytabs/broker3.keytab" ]; do 
        echo "Waiting for broker3.keytab file..."
        sleep 1
    done
    echo "broker3.keytab file found"
fi

if [[ ! -f /opt/data/metadata/metadata.properties ]]; then
    /opt/kafka/bin/kafka-storage.sh format --config /opt/kafka/config/broker.properties --cluster-id h96i_0NbQrqSDy33dP9U7Q --ignore-formatted
fi

/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/broker.properties