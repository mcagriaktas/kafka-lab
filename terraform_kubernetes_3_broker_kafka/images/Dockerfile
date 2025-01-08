FROM openjdk:17-slim-bullseye

RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/kafka && \
    mkdir -p /opt/jmx_exporter && \
    mkdir /kafka && \
    mkdir -p /data/kafka

RUN curl "https://archive.apache.org/dist/kafka/3.8.0/kafka_2.13-3.8.0.tgz" \
    -o /opt/kafka/kafka.tgz && \
    cd /kafka && \
    tar -xvzf /opt/kafka/kafka.tgz --strip 1 && \
    rm /opt/kafka/kafka.tgz

COPY server.properties /kafka/config/server.properties
COPY start-kafka.sh /usr/bin

RUN chmod +x /usr/bin/start-kafka.sh

WORKDIR /kafka/bin

CMD ["start-kafka.sh"]