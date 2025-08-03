FROM openjdk:17-jdk-slim

ENV KAFKA_UI_VERSION=v0.7.2

RUN apt update && apt install -y wget

RUN mkdir -p /opt/kafka-ui

WORKDIR /opt/kafka-ui

RUN wget https://github.com/provectus/kafka-ui/releases/download/${KAFKA_UI_VERSION}/kafka-ui-api-${KAFKA_UI_VERSION}.jar -P /opt/kafka-ui

COPY ./init-sh/provectus-starter.sh /usr/bin/provectus-starter.sh

RUN chmod +x /usr/bin/provectus-starter.sh 

CMD ["provectus-starter.sh"]