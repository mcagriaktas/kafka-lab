FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive
ENV KERBEROS_HOME=/mnt

RUN apt-get update && \
    apt-get install -y \
    krb5-user \
    libpam-krb5 \
    libkrb5-dev \
    krb5-kdc \
    krb5-admin-server \
    krb5-kdc-ldap \
    krb5-config \
    ldap-utils \
    libterm-readline-perl-perl \
    dialog \
    netcat-traditional \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/krb5kdc \
    && mkdir -p /etc/krb5kdc \
    && mkdir -p /var/log/kerberos

COPY init-sh/starter-kerberos.sh /usr/bin/starter-kerberos.sh
RUN chmod +x /usr/bin/starter-kerberos.sh

RUN touch /var/log/krb5kdc.log /var/log/kadmin.log \
    && chmod 644 /var/log/krb5kdc.log /var/log/kadmin.log

WORKDIR ${KERBEROS_HOME}

CMD [ "starter-kerberos.sh"]