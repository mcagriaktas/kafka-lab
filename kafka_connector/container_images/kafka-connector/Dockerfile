FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ENV KAFKA_VERSION=3.8.0
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/kafka
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=${PATH}:${KAFKA_HOME}/bin:${JAVA_HOME}/bin

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

RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    mv kafka_${SCALA_VERSION}-${KAFKA_VERSION} /kafka && \
    rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN mkdir -p /kafka/plugins /etc/kafka/

RUN wget https://d2p6pa21dvn84.cloudfront.net/api/plugins/couchbase/kafka-connect-couchbase/versions/4.2.6/couchbase-kafka-connect-couchbase-4.2.6.zip && \
    mkdir -p /kafka/plugins/kafka-connect-couchbase && \
    unzip couchbase-kafka-connect-couchbase-4.2.6.zip -d /kafka/plugins/kafka-connect-couchbase && \
    rm couchbase-kafka-connect-couchbase-4.2.6.zip

COPY connect-distributed.properties /etc/kafka/connect-distributed.properties
COPY start-kafka-connector.sh /usr/local/bin/start-kafka-connector.sh
RUN chmod +x /usr/local/bin/start-kafka-connector.sh

WORKDIR /etc/kafka

EXPOSE 8083

CMD ["start-kafka-connector.sh"]