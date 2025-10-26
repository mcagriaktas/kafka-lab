FROM openjdk:17.0.1-jdk-slim

ENV JMX_EXPORTER_HOME=/opt/jmx_exporter
ENV JMX_EXPORTER_VERSION=1.0.1

ENV KAFKA_OPTS="-Djava.security.auth.login.config=/opt/kafka/config/broker_server_jaas.conf -Djava.security.krb5.conf=/etc/krb5.conf"
ENV KAFKA_HEAP_OPTS="-Xms2G -Xmx6G"
ENV EXTRA_ARGS="-javaagent:${JMX_EXPORTER_HOME}/jmx_prometheus_javaagent.jar=7071:${JMX_EXPORTER_HOME}/broker-metrics.yml"

RUN apt-get update && \
    apt-get install -y \
    wget \
    vim \
    telnet \
    krb5-user \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd

WORKDIR /opt
RUN mkdir -p ${JMX_EXPORTER_HOME}

RUN wget https://downloads.apache.org/kafka/4.0.0/kafka_2.13-4.0.0.tgz && \
    tar -xzf kafka_2.13-4.0.0.tgz && \
    mv kafka_2.13-4.0.0 kafka && \
    rm kafka_2.13-4.0.0.tgz

RUN wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar \
    -O ${JMX_EXPORTER_HOME}/jmx_prometheus_javaagent.jar
    
COPY init-sh/broker-starter.sh /usr/bin/broker-starter.sh
COPY init-sh/kafka-starter-user-creator.sh /usr/bin/kafka-starter-user-creator.sh
COPY config/krb5.conf /etc/krb5.conf

RUN mkdir -p /opt/kafka/config/jks && \
    mkdir -p /opt/kafka/config/keytabs && \
    mkdir /kafka && \
    chmod +x /usr/bin/broker-starter.sh && \
    chmod +x /usr/bin/kafka-starter-user-creator.sh && \
    chmod 777 -R /opt/kafka/config

CMD [ "broker-starter.sh" ]