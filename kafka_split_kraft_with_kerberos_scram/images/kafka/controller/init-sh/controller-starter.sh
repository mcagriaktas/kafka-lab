#!/bin/bash

sleep 5

if [[ $HOSTNAME == "controller1" ]]; then
    while [ ! -f "/opt/kafka/config/keytabs/controller1.keytab" ]; do 
        echo "Waiting for controller1.keytab file..."
        sleep 5
    done
    echo "controller1.keytab file found"
elif [[ $HOSTNAME == "controller2" ]]; then
    while [ ! -f "/opt/kafka/config/keytabs/controller2.keytab" ]; do 
        echo "Waiting for controller2.keytab file..."
        sleep 5
    done
    echo "controller2.keytab file found"
elif [[ $HOSTNAME == "controller3" ]]; then
    while [ ! -f "/opt/kafka/config/keytabs/controller3.keytab" ]; do 
        echo "Waiting for controller3.keytab file..."
        sleep 5
    done
    echo "controller3.keytab file found"
fi

/opt/kafka/bin/kafka-storage.sh format --config /opt/kafka/config/controller.properties --cluster-id h96i_0NbQrqSDy33dP9U7Q --ignore-formatted

/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/controller.properties