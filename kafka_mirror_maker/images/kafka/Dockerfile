FROM openjdk:26-ea-17-slim

ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_DATA_HOME=/opt/data
ENV KAFKA_VERSION=4.0.0

ENV KAFKA_EXPORTER_HOME=/opt/kafka_exporter
ENV KAFKA_EXPORTER_VERSION=1.9.0

RUN apt-get update && \
    apt-get install -y curl wget net-tools && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${KAFKA_HOME} && \
    mkdir -p ${KAFKA_DATA_HOME} && \
    mkdir -p ${KAFKA_EXPORTER_HOME}

RUN wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz -O /tmp/kafka.tgz && \
    tar -xvzf /tmp/kafka.tgz -C /opt && \
    mv /opt/kafka_2.13-${KAFKA_VERSION}/* ${KAFKA_HOME} && \
    rm -rf /opt/kafka_2.13-${KAFKA_VERSION} /tmp/kafka.tgz

RUN wget https://github.com/danielqsj/kafka_exporter/releases/download/v${KAFKA_EXPORTER_VERSION}/kafka_exporter-${KAFKA_EXPORTER_VERSION}.linux-amd64.tar.gz -O /tmp/kafka_exporter.tar.gz && \
    tar -xvzf /tmp/kafka_exporter.tar.gz -C ${KAFKA_EXPORTER_HOME} && \
    mv ${KAFKA_EXPORTER_HOME}/kafka_exporter-${KAFKA_EXPORTER_VERSION}.linux-amd64/* ${KAFKA_EXPORTER_HOME} && \
    rm -rf ${KAFKA_EXPORTER_HOME}/kafka_exporter-${KAFKA_EXPORTER_VERSION}.linux-amd64 /tmp/kafka_exporter.tar.gz 

COPY init-sh/kafka-starter.sh /usr/bin
COPY init-sh/kafka-export-starter.sh /usr/bin

RUN chmod +x /usr/bin/kafka-starter.sh /usr/bin/kafka-export-starter.sh

RUN chmod -R 777 ${KAFKA_HOME} && \
    chmod -R 777 ${KAFKA_DATA_HOME} && \
    chmod -R 777 ${KAFKA_EXPORTER_HOME}

WORKDIR ${KAFKA_DATA_HOME}

CMD [ "kafka-starter.sh" ]