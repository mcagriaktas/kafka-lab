FROM openjdk:26-ea-17-slim

ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_DATA_DIR=/opt/data
ENV KAFKA_VERSION=4.0.0

RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir ${KAFKA_HOME} && \
    mkdir -p ${KAFKA_DATA_DIR}

RUN wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz -O /tmp/kafka.tgz && \
    tar -xvzf /tmp/kafka.tgz -C /opt && \
    mv /opt/kafka_2.13-${KAFKA_VERSION}/* ${KAFKA_HOME} && \
    rm -rf /opt/kafka_2.13-${KAFKA_VERSION} /tmp/kafka.tgz


COPY init-sh/kafka-starter.sh /usr/bin

RUN chmod +x /usr/bin/kafka-starter.sh
RUN chmod -R 777 ${KAFKA_HOME} && \
    chmod -R 777 ${KAFKA_DATA_DIR}

WORKDIR ${KAFKA_HOME}

CMD [ "kafka-starter.sh" ]