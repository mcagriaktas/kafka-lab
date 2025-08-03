#!/bin/bash

# Create necessary directories
mkdir -p /var/lib/krb5kdc
mkdir -p /etc/krb5kdc
mkdir -p /keytabs
mkdir -p /client-keytabs

# Function to check if KDC is running
check_kdc_running() {
    if pidof krb5kdc > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to initialize KDC
initialize_kdc() {
    echo "Creating KDC database..."
    
    # Stop KDC services if they're running
    service krb5-kdc stop
    service krb5-admin-server stop
    
    # Remove old database files if they exist
    rm -rf /var/lib/krb5kdc/*
    
    # Create new KDC database
    kdb5_util create -s -r EXAMPLE.COM -P cagri3541
    
    if [ $? -ne 0 ]; then
        echo "Failed to create KDC database"
        exit 1
    fi
    
    # Create admin principal
    echo "Creating admin principal..."
    kadmin.local -q "addprinc -pw cagri3541 admin/admin@EXAMPLE.COM"

    # Producer Container's User
    echo "Creating broker principal and keytab..."
    kadmin.local -q "addprinc -randkey client/client@EXAMPLE.COM"
    kadmin.local -q "ktadd -k /keytabs/client-keytabs/client-client.keytab client/client@EXAMPLE.COM"

    # Create broker principal and keytab
    echo "Creating broker principal and keytab..."
    kadmin.local -q "addprinc -randkey kafka/broker@EXAMPLE.COM"
    kadmin.local -q "ktadd -k /keytabs/kafka-keytabs/kafka-broker.keytab kafka/broker@EXAMPLE.COM"
    
    # Create controller principal and keytab
    echo "Creating controller principal and keytab..."
    kadmin.local -q "addprinc -randkey kafka/controller@EXAMPLE.COM"
    kadmin.local -q "ktadd -k /keytabs/kafka-keytabs/kafka-controller.keytab kafka/controller@EXAMPLE.COM"
    
    # Set proper permissions for keytabs
    chmod 777 -R /keytabs
}

# Check KDC database and initialize if needed
if [ ! -f /var/lib/krb5kdc/principal ] || [ ! -s /var/lib/krb5kdc/principal ]; then
    echo "No valid KDC database found. Initializing..."
    initialize_kdc
else
    echo "KDC database exists, checking integrity..."
    if ! check_kdc_running; then
        echo "KDC not running with existing database. Reinitializing..."
        initialize_kdc
    fi
fi

# Start Kerberos services
echo "Starting Kerberos services..."
service krb5-kdc start
if [ $? -ne 0 ]; then
    echo "Failed to start krb5kdc"
    exit 1
fi

service krb5-admin-server start
if [ $? -ne 0 ]; then
    echo "Failed to start kadmind"
    exit 1
fi

echo "Verifying Kerberos services..."
if check_kdc_running; then
    echo "KDC is running successfully"
else
    echo "KDC failed to start"
    exit 1
fi

echo "Checking kadmind..."
if pidof kadmind > /dev/null; then
    echo "kadmind is running successfully"
else
    echo "kadmind failed to start"
    exit 1
fi

sudo chmod 777 -R /keytabs

echo "Kerberos setup completed successfully"

# Keep container running and log to stdout
tail -f /var/log/krb5kdc.log /var/log/kadmin.log 2>/dev/null