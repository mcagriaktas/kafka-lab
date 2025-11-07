FROM openjdk:26-ea-17-slim

RUN apt update && apt install -y wget

WORKDIR /opt

RUN wget https://github.com/kafbat/kafka-ui/releases/download/v1.2.0/api-v1.2.0.jar -O kafka-ui-api-v1.2.0.jar

RUN mkdir -p /opt/jks

COPY ./init-sh/kafka-ui-starter.sh /usr/bin

RUN chmod +x /usr/bin/kafka-ui-starter.sh 

CMD [ "kafka-ui-starter.sh" ]