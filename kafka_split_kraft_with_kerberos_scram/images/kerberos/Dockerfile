FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    krb5-user \
    libpam-krb5 \
    libkrb5-dev \
    krb5-kdc \
    krb5-admin-server \
    krb5-config \
    libterm-readline-perl-perl \
    dialog \
    netcat-traditional \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/krb5kdc \
    && mkdir -p /etc/krb5kdc \
    && mkdir -p /keytabs \
    && mkdir -p /client-keytabs \
    && mkdir -p /var/log/kerberos

COPY config/krb5.conf /etc/krb5.conf
COPY config/kdc.conf /etc/krb5kdc/kdc.conf
COPY config/kadm5.acl /etc/krb5kdc/kadm5.acl

RUN chown -R root:root /etc/krb5.conf /etc/krb5kdc \
    && chmod 644 /etc/krb5.conf \
    && chmod 644 /etc/krb5kdc/kdc.conf \
    && chmod 644 /etc/krb5kdc/kadm5.acl \
    && chmod 750 /var/lib/krb5kdc \
    && chmod 750 /keytabs

COPY init-sh/starter-kerberos.sh /usr/bin/starter-kerberos.sh
RUN chmod +x /usr/bin/starter-kerberos.sh

RUN touch /var/log/krb5kdc.log /var/log/kadmin.log \
    && chmod 644 /var/log/krb5kdc.log /var/log/kadmin.log

CMD [ "starter-kerberos.sh"]