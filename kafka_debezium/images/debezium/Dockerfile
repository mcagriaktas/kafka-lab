FROM openjdk:26-ea-17-slim

ENV DEBEZIUM_VERSION=3.1.1.Final
ENV KAFKA_VERSION=4.0.0
ENV KAFKA_HOME=/opt/kafka

ENV KAFKA_CONNECT_PLUGINS_DIR=/opt/debezium

ENV JMX_EXPORTER_HOME=/opt/jmx_exporter
ENV JMX_EXPORTER_VERSION=1.0.1

RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${KAFKA_HOME} && \
    mkdir -p ${KAFKA_CONNECT_PLUGINS_DIR} && \
    mkdir -p ${JMX_EXPORTER_HOME} && \
    mkdir -p /data/kafka-connect

RUN wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz \
    -O /tmp/kafka.tgz && \
    tar -xzf /tmp/kafka.tgz -C ${KAFKA_HOME} --strip-components=1 && \
    rm /tmp/kafka.tgz

RUN wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${DEBEZIUM_VERSION}/debezium-connector-postgres-${DEBEZIUM_VERSION}-plugin.tar.gz \
    -O /tmp/debezium-postgres.tar.gz && \
    tar -xzf /tmp/debezium-postgres.tar.gz -C ${KAFKA_CONNECT_PLUGINS_DIR} && \
    rm /tmp/debezium-postgres.tar.gz

RUN wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-jdbc/${DEBEZIUM_VERSION}/debezium-connector-jdbc-${DEBEZIUM_VERSION}-plugin.tar.gz \
    -O /tmp/debezium-jdbc.tar.gz && \
    tar -xzf /tmp/debezium-jdbc.tar.gz -C ${KAFKA_CONNECT_PLUGINS_DIR} && \
    rm /tmp/debezium-jdbc.tar.gz

RUN wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar \
-O ${JMX_EXPORTER_HOME}/jmx_prometheus_javaagent.jar

COPY ./init-sh/debezium-starter.sh /usr/bin/
RUN chmod +x /usr/bin/debezium-starter.sh

ENTRYPOINT ["/usr/bin/debezium-starter.sh"]