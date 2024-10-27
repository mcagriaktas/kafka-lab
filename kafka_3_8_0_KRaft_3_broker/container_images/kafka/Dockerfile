FROM openjdk:17-slim-bullseye

RUN apt-get update && \
    apt-get install -y curl

RUN  mkdir /opt/kafka && \
    curl "https://archive.apache.org/dist/kafka/3.8.0/kafka_2.13-3.8.0.tgz" \
    -o /opt/kafka/kafka.tgz && \
    mkdir /kafka && cd /kafka && \
    tar -xvzf /opt/kafka/kafka.tgz --strip 1

RUN mkdir -p /data/kafka

COPY start-kafka.sh  /usr/bin

RUN chmod +x  /usr/bin/start-kafka.sh

WORKDIR /kafka/bin

CMD ["start-kafka.sh"]