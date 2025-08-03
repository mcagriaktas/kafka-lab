#!/bin/bash
# ======================================================================================
# The starter-controller.sh is preparing to the container for kafka authentication. -
# ======================================================================================

create_keys() {

    echo "Creating controller's keystore..."
    keytool -genkey \
        -alias controller \
        -keyalg RSA \
        -keysize 2048 \
        -keystore /opt/kafka/config/kraft/keys/controller.keystore.jks \
        -storepass cagri3541 \
        -keypass cagri3541 \
        -dname "CN=controller, OU=kafka, O=example, L=kafka, ST=kafka, C=kafka"

    echo "Exporting controller's certificate..."
    keytool -exportcert \
        -alias controller \
        -keystore /opt/kafka/config/kraft/keys/controller.keystore.jks \
        -file /opt/kafka/config/kraft/keys/controller.cert \
        -storepass cagri3541

    echo "Creating controller's truststore..."
    keytool -keystore /opt/kafka/config/kraft/keys/controller.truststore.jks \
        -alias controller \
        -importcert \
        -file /opt/kafka/config/kraft/keys/controller.cert \
        -storepass cagri3541 \
        -noprompt

    # ==================================================================================
    # If you don't want to add the broker.truststore.jks in your controller.properties -
    # you can open the comment lines below to import the broker's certificate to the   -
    # controller's truststore.                                                         - 
    # ==================================================================================

    # import_broker_cert

    chmod 777 -R /opt/kafka/config/kraft/keys
}

import_broker_cert() {
    echo "Waiting for broker certificate..."
    while [ ! -f /opt/kafka/config/kraft/keys/broker.cert ]; do
        sleep 5
        echo "Still waiting for broker.cert..."
    done

    echo "Importing broker's certificate..."
    keytool -importcert \
        -alias broker \
        -file /opt/kafka/config/kraft/keys/broker.cert \
        -keystore /opt/kafka/config/kraft/keys/controller.truststore.jks \
        -storepass cagri3541 \
        -noprompt
}

check_keytab() {
    while [ ! -f "/opt/kafka/config/kraft/keytabs/kafka-controller.keytab" ]; do 
        echo "Waiting for kafka-controller.keytab file..."
        sleep 5
    done
    echo "kafka-controller.keytab file found"
}

if grep -q "^[[:space:]]*import_broker_cert" "$0"; then
    required_keys=("controller.keystore.jks" "controller.truststore.jks" "broker.truststore.jks" "broker.cert")
else 
    required_keys=("controller.keystore.jks" "controller.truststore.jks" "broker.truststore.jks")
fi
keys_missing=false

for key in "${required_keys[@]}"; do
    if [ ! -f "/opt/kafka/config/kraft/keys/$key" ]; then
        keys_missing=true
        break
    fi
done

if [ "$keys_missing" = true ]; then
    echo "Some keys are missing, checking keytab first..."
    check_keytab
    echo "Creating missing keys..."
    create_keys
else
    echo "All keys exist"
fi

if [ ! -f "/kafka/kraft-controller-logs/meta.properties" ]; then
    echo "Formatting storage directory..."
    
    /opt/kafka/bin/kafka-storage.sh format \
        --config /opt/kafka/config/kraft/controller.properties \
        --cluster-id h96i_0NbQrqSDy33dP9U7Q
    
    if [ ! -f "/kafka/kraft-controller-logs/meta.properties" ]; then
        echo "meta.properties file was not created after formatting"
        exit 1
    fi
    
    echo "Storage directory formatted successfully"
else
    echo "Storage directory already formatted, meta.properties exists"
fi

echo "Starting Kafka controller..."
exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/controller.properties