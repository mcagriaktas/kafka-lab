FROM openjdk:17-slim-bullseye

RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/kafka && \
    mkdir -p /data/kafka

RUN curl "https://archive.apache.org/dist/kafka/3.8.0/kafka_2.13-3.8.0.tgz" \
    -o /opt/kafka/kafka.tgz && \
    cd /opt/kafka && \
    tar -xvzf kafka.tgz --strip 1 && \
    rm kafka.tgz

COPY init-sh/kafka-starter.sh /opt/kafka/bin/kafka-starter.sh

RUN chmod +x /opt/kafka/bin/kafka-starter.sh

WORKDIR /opt/kafka/bin

CMD ["/opt/kafka/bin/kafka-starter.sh"]