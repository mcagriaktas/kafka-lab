FROM openjdk:17-slim-bullseye

ENV KAFKA_VERSION=4.0.0
ENV KAFKA_HOME=/opt/kafka

RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/kafka && \
    mkdir -p /data/kafka

RUN wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz \
    -O /tmp/kafka.tgz && \
    tar -xzf /tmp/kafka.tgz -C ${KAFKA_HOME} --strip-components=1 && \
    rm /tmp/kafka.tgz

COPY ./init-sh/kafka-starter.sh /usr/bin

RUN chmod +x /usr/bin/kafka-starter.sh

WORKDIR /opt/kafka/bin

CMD [ "kafka-starter.sh" ]