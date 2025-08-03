FROM ubuntu:24.04

ENV KAFKA_VERSION=4.0.0
ENV KAFKA_HOME=/opt/kafka

RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    openjdk-17-jdk \
    netcat-openbsd \
    gnupg \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${KAFKA_HOME} ${KAFKA_HOME}/plugins 

RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz && \
    tar -xzf kafka_2.13-${KAFKA_VERSION}.tgz && \
    mv kafka_2.13-${KAFKA_VERSION}/* ${KAFKA_HOME} && \
    rm -rf kafka_2.13-${KAFKA_VERSION}.tgz kafka_2.13-${KAFKA_VERSION}

RUN wget https://d2p6pa21dvn84.cloudfront.net/api/plugins/couchbase/kafka-connect-couchbase/versions/4.2.6/couchbase-kafka-connect-couchbase-4.2.6.zip && \
    mkdir -p ${KAFKA_HOME}/plugins/kafka-connect-couchbase && \
    unzip couchbase-kafka-connect-couchbase-4.2.6.zip -d ${KAFKA_HOME}/plugins/kafka-connect-couchbase && \
    rm couchbase-kafka-connect-couchbase-4.2.6.zip

COPY ./init-sh/kafka-connector-starter.sh /usr/bin
RUN chmod +x /usr/bin/kafka-connector-starter.sh

WORKDIR /opt/kafka

CMD [ "kafka-connector-starter.sh" ]