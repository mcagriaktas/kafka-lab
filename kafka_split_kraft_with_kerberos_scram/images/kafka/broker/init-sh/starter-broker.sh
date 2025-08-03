#!/bin/bash

# ======================================================================================
# The starter-broker.sh is preparing to the container for kafka authentication.     -
# ======================================================================================

create_keys() {

    echo "Creating broker's keystore..."
    keytool -genkey \
        -alias broker \
        -keyalg RSA \
        -keysize 2048 \
        -keystore /opt/kafka/config/kraft/keys/broker.keystore.jks \
        -storepass cagri3541 \
        -keypass cagri3541 \
        -dname "CN=broker, OU=kafka, O=example, L=kafka, ST=kafka, C=kafka" \
        -storetype PKCS12

    echo "Exporting broker's certificate..."
    keytool -exportcert \
        -alias broker \
        -keystore /opt/kafka/config/kraft/keys/broker.keystore.jks \
        -file /opt/kafka/config/kraft/keys/broker.cert \
        -storepass cagri3541 \
        -rfc

    echo "Creating broker's truststore..."
    keytool -importcert \
        -alias broker \
        -file /opt/kafka/config/kraft/keys/broker.cert \
        -keystore /opt/kafka/config/kraft/keys/broker.truststore.jks \
        -storepass cagri3541 \
        -noprompt \
        -storetype PKCS12

    echo "Exporting client's truststore..."
    keytool -importcert \
        -alias broker \
        -file /opt/kafka/config/kraft/keys/broker.cert \
        -keystore /opt/kafka/config/kraft/keys/client.truststore.jks \
        -storepass cagri3541 \
        -noprompt \
        -storetype PKCS12

    echo "Exporting client's CA certificate..."
    keytool -exportcert \
        -alias broker \
        -keystore /opt/kafka/config/kraft/keys/broker.truststore.jks \
        -file /opt/kafka/config/kraft/keys/client.pem \
        -rfc \
        -storepass cagri3541 \
        -storetype PKCS12

    # ==================================================================================
    # If you don't want to add the controller.truststore.jks in your broker.properties -
    # you can open the comment lines below to import the controller's certificate to   -
    # the broker's truststore.                                                         - 
    # ==================================================================================
    
    # import_controller_cert

    chmod 777 -R /opt/kafka/config/kraft/keys
}

import_controller_cert() {
    echo "Waiting for controller certificate..."
    while [ ! -f /opt/kafka/config/kraft/keys/controller.cert ]; do
        sleep 5
        echo "Still waiting for controller.cert..."
    done

    echo "Importing controller's certificate..."
    keytool -importcert \
        -alias controller \
        -file /opt/kafka/config/kraft/keys/controller.cert \
        -keystore /opt/kafka/config/kraft/keys/broker.truststore.jks \
        -storepass cagri3541 \
        -noprompt
}

check_keytab() {
    while [ ! -f "/opt/kafka/config/kraft/keytabs/kafka-broker.keytab" ]; do 
        echo "Waiting for kafka-broker.keytab file..."
        sleep 5
    done
    echo "kafka-broker.keytab file found"
}

if grep -q "^[[:space:]]*import_broker_cert" "$0"; then
    required_keys=("broker.keystore.jks" "broker.truststore.jks" "controller.truststore.jks" "controller.cert")
else 
    required_keys=("broker.keystore.jks" "broker.truststore.jks" "controller.truststore.jks")
fi
keys_missing=false

for key in "${required_keys[@]}"; do
    if [ ! -f "/opt/kafka/config/kraft/keys/$key" ]; then
        sleep 1
        keys_missing=true
        break
    fi
done

if [ "$keys_missing" = true ]; then
    echo "Some keys are missing, checking cert/store files first..."
    check_keytab
    echo "Creating missing keys..."
    create_keys
else
    echo "All keys exist"
fi

if [ ! -f "/kafka/kraft-broker-logs/meta.properties" ]; then
    echo "Formatting storage directory..."
    
    /opt/kafka/bin/kafka-storage.sh format \
        --config /opt/kafka/config/kraft/broker.properties \
        --cluster-id h96i_0NbQrqSDy33dP9U7Q
    
    if [ ! -f "/kafka/kraft-broker-logs/meta.properties" ]; then
        echo "meta.properties file was not created after formatting"
        exit 1
    fi
    
    echo "Storage directory formatted successfully"
else
    echo "Storage directory already formatted, meta.properties exists"
fi

echo "Waiting for controller to become available..."
while true; do
    if echo > /dev/tcp/controller/9093 2>/dev/null; then
        echo "Controller is reachable"
        echo "Starting Kafka..."
        exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/broker.properties
    else
        echo "Controller is not reachable, retrying in 5 seconds..."
        sleep 5
    fi
done