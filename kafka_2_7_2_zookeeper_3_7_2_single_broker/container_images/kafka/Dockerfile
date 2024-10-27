FROM openjdk:11-jre-slim

ENV KAFKA_VERSION=2.7.2
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

RUN apt-get update && apt-get install -y \
    wget \
    tar \
    netcat \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz \
    && tar -xvzf kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz \
    && mv kafka_$SCALA_VERSION-$KAFKA_VERSION /kafka \
    && rm kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz

EXPOSE 9092

WORKDIR /kafka/bin

CMD ["/kafka/bin/kafka-server-start.sh", "/kafka/config/server.properties"]