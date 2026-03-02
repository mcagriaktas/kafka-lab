FROM openjdk:17.0.2-slim-bullseye

ENV TZ=Europe/Istanbul

ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_VERSION=4.2.0
ENV KAFKA_HEAP_OPTS="-Xms2G -Xmx6G"
ENV KAFKA_OPTS_STATIC="-Djava.security.auth.login.config=/opt/kafka/config/controller_server_jaas.conf \
  -Dorg.apache.kafka.sasl.oauthbearer.allowed.urls=https://keycloak.dahbest.kfn:8443/realms/master/protocol/openid-connect/certs,https://keycloak.dahbest.kfn:8443/realms/master/protocol/openid-connect/token \
  -Djavax.net.ssl.trustStorePassword=cagri3541"

RUN apt-get update && \
    apt-get install -y \
    wget \
    curl \
    vim \
    telnet \
    krb5-user \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd

RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz && \
    tar -xzf kafka_2.13-${KAFKA_VERSION}.tgz && \
    mv kafka_2.13-${KAFKA_VERSION} ${KAFKA_HOME} && \
    rm kafka_2.13-${KAFKA_VERSION}.tgz

COPY init-sh/controller-starter.sh /usr/bin/controller-starter.sh
RUN chmod +x /usr/bin/controller-starter.sh

RUN mkdir -p ${KAFKA_HOME}/config/jks && \
    chmod 777 -R ${KAFKA_HOME}/config

WORKDIR /opt

CMD [ "controller-starter.sh" ]