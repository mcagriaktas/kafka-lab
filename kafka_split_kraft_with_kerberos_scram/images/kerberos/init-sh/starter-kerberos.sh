#!/bin/bash

sleep 5

set -euo pipefail

chmod 644 /etc/krb5.conf
chmod 644 /etc/krb5kdc/kdc.conf
chmod 644 /etc/krb5kdc/kadm5.acl
chmod 750 /var/lib/krb5kdc

echo "Waiting for LDAP server to be ready..."
until ldapsearch -x -H ldap://ldap:389 -b "dc=dahbest,dc=com" > /dev/null 2>&1; do
    echo "LDAP server not ready, waiting..."
    sleep 5
done
echo "LDAP server is ready. Proceeding..."

: "${KRB5_REALM:=DAHBEST.KFN}"
: "${DNS_DOMAIN:=dahbest.kfn}"
: "${KRB5_ADMIN_PASSWORD:=cagri3541}"

mkdir -p /var/lib/krb5kdc
mkdir -p /etc/krb5kdc
mkdir -p /mnt/keytabs

mkdir -p /mnt/keytabs/broker1
mkdir -p /mnt/keytabs/broker2
mkdir -p /mnt/keytabs/broker3
mkdir -p /mnt/keytabs/controller1
mkdir -p /mnt/keytabs/controller2
mkdir -p /mnt/keytabs/controller3
mkdir -p /mnt/keytabs/client

initialize_kdc() {
    echo "Creating KDC database for realm: ${KRB5_REALM} in LDAP..."
    
    service krb5-kdc stop || true
    service krb5-admin-server stop || true

    printf '%s\n%s\n' "${KRB5_ADMIN_PASSWORD}" "${KRB5_ADMIN_PASSWORD}" | \
        kdb5_ldap_util \
            -D cn=admin,dc=dahbest,dc=com \
            -w 35413541 \
            create \
            -subtrees cn=kerberos,dc=dahbest,dc=com \
            -containerref cn=kerberos,dc=dahbest,dc=com \
            -r "${KRB5_REALM}" \
            -s

    sleep 1

    printf '%s\n%s\n' "35413541" "35413541" | \
        kdb5_ldap_util \
            -D cn=admin,dc=dahbest,dc=com \
            -w 35413541 \
            stashsrvpw \
            -f /etc/krb5kdc/service.keyfile \
            cn=admin,dc=dahbest,dc=com

    if [ $? -ne 0 ]; then
        echo "Failed to create KDC database in LDAP"
        exit 1
    fi

    echo "Creating admin principal..."
    kadmin.local -q "addprinc -pw ${KRB5_ADMIN_PASSWORD} admin/admin@${KRB5_REALM}"

    if [[ -f /mnt/keytabs/client/client.keytab ]]; then
        rm -f /mnt/keytabs/client/client.keytab
        echo "Client keytab already exists, removing..."
    fi
    echo "Creating client principal and keytab..."
    CLIENT_FQDN="client.${DNS_DOMAIN}"
    kadmin.local -q "addprinc -randkey client/${CLIENT_FQDN}@${KRB5_REALM}"
    kadmin.local -q "ktadd -k /mnt/keytabs/client/client.keytab client/${CLIENT_FQDN}@${KRB5_REALM}"

    for i in 1 2 3; do
        if [[ -f /mnt/keytabs/broker${i}/broker${i}.keytab ]]; then
            rm -f /mnt/keytabs/broker${i}/broker${i}.keytab
            echo "Broker${i} keytab already exists, removing..."
        fi
        echo "Creating broker${i} principal and keytab..."
        BROKER_FQDN="broker${i}.${DNS_DOMAIN}"

        kadmin.local -q "addprinc -randkey broker/${BROKER_FQDN}@${KRB5_REALM}"
        kadmin.local -q "addprinc -randkey controller/${BROKER_FQDN}@${KRB5_REALM}"

        kadmin.local -q "ktadd -k /mnt/keytabs/broker${i}/broker${i}.keytab broker/${BROKER_FQDN}@${KRB5_REALM}"
        kadmin.local -q "ktadd -k /mnt/keytabs/broker${i}/broker${i}.keytab controller/${BROKER_FQDN}@${KRB5_REALM}"
    done

    for i in 1 2 3; do
        if [[ -f /mnt/keytabs/controller${i}/controller${i}.keytab ]]; then
            rm -f /mnt/keytabs/controller${i}/controller${i}.keytab
            echo "Controller${i} keytab already exists, removing..."
        fi
        echo "Creating controller${i} principal and keytab..."
        CONTROLLER_FQDN="controller${i}.${DNS_DOMAIN}"

        kadmin.local -q "addprinc -randkey controller/${CONTROLLER_FQDN}@${KRB5_REALM}"
        kadmin.local -q "ktadd -k /mnt/keytabs/controller${i}/controller${i}.keytab controller/${CONTROLLER_FQDN}@${KRB5_REALM}"

    done

    chmod 777 -R /mnt/keytabs
}

check_kdc_running() {
    if pidof krb5kdc > /dev/null; then
        return 0
    else
        return 1
    fi
}

if ! ldapsearch -x -H ldap://ldap:389 -D "cn=admin,dc=dahbest,dc=com" -w 35413541 -b "ou=kerberos,dc=dahbest,dc=com" "krbPrincipalName=admin/admin@DAHBEST.KFN" | grep -q "numEntries: 1"; then
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
if ! service krb5-kdc start; then
    echo "Failed to start krb5-kdc"
    exit 1
fi

if ! service krb5-admin-server start; then
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

chmod 777 -R /mnt/keytabs

echo "Kerberos setup completed successfully"

tail -f /var/log/krb5kdc.log /var/log/kadmin.log 2>/dev/null