#!/bin/bash

sleep 5

set -euo pipefail

: "${KRB5_REALM:=DAHBEST.KFN}"
: "${KRB5_ADMIN_PASSWORD:=cagri3541}"
: "${DNS_DOMAIN:=dahbest.kfn}"

mkdir -p /var/lib/krb5kdc
mkdir -p /etc/krb5kdc
mkdir -p /mnt/keytabs

mkdir -p /mnt/keytabs/kafka-keytabs/broker1
mkdir -p /mnt/keytabs/kafka-keytabs/broker2
mkdir -p /mnt/keytabs/kafka-keytabs/broker3
mkdir -p /mnt/keytabs/kafka-keytabs/controller1
mkdir -p /mnt/keytabs/kafka-keytabs/controller2
mkdir -p /mnt/keytabs/kafka-keytabs/controller3
mkdir -p /mnt/keytabs/kafka-keytabs/client

check_kdc_running() {
    if pidof krb5kdc > /dev/null; then
        return 0
    else
        return 1
    fi
}

initialize_kdc() {
    echo "Creating KDC database for realm: ${KRB5_REALM}..."
    
    service krb5-kdc stop || true
    service krb5-admin-server stop || true
    
    rm -rf /var/lib/krb5kdc/*
    
    kdb5_util create -s -r "${KRB5_REALM}" -P "${KRB5_ADMIN_PASSWORD}"
    
    if [ $? -ne 0 ]; then
        echo "Failed to create KDC database"
        exit 1
    fi

    echo "Creating admin principal..."
    kadmin.local -q "addprinc -pw ${KRB5_ADMIN_PASSWORD} admin/admin@${KRB5_REALM}"

    echo "Creating client principal and keytab..."
    CLIENT_FQDN="client.${DNS_DOMAIN}"
    kadmin.local -q "addprinc -randkey client/${CLIENT_FQDN}@${KRB5_REALM}"
    kadmin.local -q "ktadd -k /mnt/keytabs/kafka-keytabs/client/client.keytab client/${CLIENT_FQDN}@${KRB5_REALM}"

    for i in 1 2 3; do
        echo "Creating broker${i} principal and keytab..."
        BROKER_FQDN="broker${i}.${DNS_DOMAIN}"
        kadmin.local -q "addprinc -randkey kafka/${BROKER_FQDN}@${KRB5_REALM}"
        kadmin.local -q "ktadd -k /mnt/keytabs/kafka-keytabs/broker${i}/broker${i}.keytab kafka/${BROKER_FQDN}@${KRB5_REALM}"
    done

    for i in 1 2 3; do
        echo "Creating controller${i} principal and keytab..."
        CONTROLLER_FQDN="controller${i}.${DNS_DOMAIN}"
        kadmin.local -q "addprinc -randkey controller/${CONTROLLER_FQDN}@${KRB5_REALM}"
        kadmin.local -q "ktadd -k /mnt/keytabs/kafka-keytabs/controller${i}/controller${i}.keytab controller/${CONTROLLER_FQDN}@${KRB5_REALM}"

    done

    chmod 777 -R /keytabs
}

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

chmod 777 -R /keytabs

echo "Kerberos setup completed successfully"

tail -f /var/log/krb5kdc.log /var/log/kadmin.log 2>/dev/null