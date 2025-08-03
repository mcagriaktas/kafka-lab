FROM openjdk:17-slim-bullseye

ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_DATA_HOME=/opt/data
ENV KAFKA_VERSION=4.0.0

ENV JMX_EXPORTER_HOME=/opt/jmx_exporter
ENV JMX_EXPORTER_VERSION=1.0.1

ENV KAFKA_EXPORTER_HOME=/opt/kafka_exporter
ENV KAFKA_EXPORTER_VERSION=1.9.0

RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir ${KAFKA_HOME} && \
    mkdir -p ${JMX_EXPORTER_HOME} && \
    mkdir ${KAFKA_EXPORTER_HOME} && \
    mkdir -p ${KAFKA_DATA_HOME}

RUN wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz -O /tmp/kafka.tgz && \
    tar -xvzf /tmp/kafka.tgz -C /opt && \
    mv /opt/kafka_2.13-${KAFKA_VERSION}/* ${KAFKA_HOME} && \
    rm -rf /opt/kafka_2.13-${KAFKA_VERSION} /tmp/kafka.tgz

RUN wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar \
    -O ${JMX_EXPORTER_HOME}/jmx_prometheus_javaagent.jar

RUN wget "https://github.com/danielqsj/kafka_exporter/releases/download/v${KAFKA_EXPORTER_VERSION}/kafka_exporter-${KAFKA_EXPORTER_VERSION}.linux-amd64.tar.gz" \
    -O /tmp/kafka_exporter.tar.gz && \
    tar -xvzf /tmp/kafka_exporter.tar.gz -C /opt && \
    mv /opt/kafka_exporter-${KAFKA_EXPORTER_VERSION}.linux-amd64/* ${KAFKA_EXPORTER_HOME} && \
    rm /tmp/kafka_exporter.tar.gz && rm -rf /opt/kafka_exporter-${KAFKA_EXPORTER_VERSION}.linux-amd64

COPY init-sh/kafka-starter.sh /usr/bin
COPY init-sh/kafka-export-starter.sh /usr/bin

RUN chmod +x /usr/bin/kafka-starter.sh /usr/bin/kafka-export-starter.sh

RUN chmod -R 777 /opt

WORKDIR ${KAFKA_HOME}

CMD [ "kafka-starter.sh" ]