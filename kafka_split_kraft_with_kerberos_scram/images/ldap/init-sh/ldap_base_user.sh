#!/bin/bash

echo " ##### You can check example files in /configs/ldap/ldap_ldif/* path. ##### "

GROUPS_PATH="/opt/ldap/ldap_ldif/groups/"
USERS_PATH="/opt/ldap/ldap_ldif/users/"

sleep 30

echo "Adding groups..."
for file in $GROUPS_PATH/*.ldif; do
    if [ -f "$file" ]; then
        echo "Adding group from file: $file"
        ldapadd -x -D 'cn=admin,dc=dahbest,dc=com' -w 35413541 -f /opt/ldap/ldap_ldif/groups/$(basename "$file")
        sleep 1
    else
        echo "No group LDIF files found in $GROUPS_PATH"
    fi
done

echo "Adding users..."
for file in $USERS_PATH/*.ldif; do
    if [ -f "$file" ]; then
        echo "Adding user from file: $file"
        ldapadd -x -D 'cn=admin,dc=dahbest,dc=com' -w 35413541 -f /opt/ldap/ldap_ldif/users/$(basename "$file")
        sleep 1
    else
        echo "No user LDIF files found in $USERS_PATH"
    fi
done
