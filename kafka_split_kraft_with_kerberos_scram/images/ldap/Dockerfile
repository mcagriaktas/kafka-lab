FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive

ENV LDAP_HOME=/opt

RUN apt-get update && apt-get install -y \
    slapd \
    ldap-utils \
    krb5-kdc-ldap \
    krb5-user \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./config/kerberos.schema /etc/ldap/schema/kerberos.schema
COPY ./config/krb5.conf /etc/krb5.conf

RUN mkdir -p /var/lib/ldap /run/slapd && \
    chown -R openldap:openldap /var/lib/ldap /run/slapd

COPY init-sh/ldap-starter.sh /usr/bin/
COPY init-sh/ldap_base_user.sh /usr/bin/ldap_base_user.sh

RUN chmod +x /usr/bin/ldap-starter.sh
RUN chmod +x /usr/bin/ldap_base_user.sh

WORKDIR ${LDAP_HOME}

CMD ["ldap-starter.sh"]