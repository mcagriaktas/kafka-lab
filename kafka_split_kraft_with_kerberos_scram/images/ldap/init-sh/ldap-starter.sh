#!/bin/bash

echo "Starting LDAP server..."
/usr/sbin/slapd -f /opt/ldap/slapd.conf -h "ldap:/// ldapi:///" -d -1 &

sleep 10

echo "Creating base.ldif setting..."
ldapadd -x -D "cn=admin,dc=dahbest,dc=com" -w 35413541 -f /opt/ldap/ldif/base.ldif

sleep 1

echo "Creating ou_users.ldif setting..."
ldapadd -x -D "cn=admin,dc=dahbest,dc=com" -w 35413541 -f /opt/ldap/ldif/ou_users.ldif

sleep 1

echo "Creating ou_groups.ldif setting..."
ldapadd -x -D "cn=admin,dc=dahbest,dc=com" -w 35413541 -f /opt/ldap/ldif/ou_groups.ldif

sleep 1

echo "Creating ou_kerberos.ldif setting..."
ldapadd -x -D "cn=admin,dc=dahbest,dc=com" -w 35413541 -f /opt/ldap/ldif/ou_kerberos.ldif

ldap_base_user.sh &

echo "All settings have been done."

tail -f /dev/null