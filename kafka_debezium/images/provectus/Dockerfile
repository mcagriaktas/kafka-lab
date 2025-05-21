FROM openjdk:17-jdk-slim

RUN apt update && apt install -y wget

RUN mkdir -p /opt/kafka-ui

WORKDIR /opt/kafka-ui

RUN wget https://github.com/provectus/kafka-ui/releases/download/v0.7.2/kafka-ui-api-v0.7.2.jar -P /opt/kafka-ui

COPY ./init-sh/provectus-starter.sh /usr/bin/provectus-starter.sh

RUN chmod +x /usr/bin/provectus-starter.sh 

CMD ["provectus-starter.sh"]