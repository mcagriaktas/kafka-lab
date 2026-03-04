FROM openjdk:22-jdk-slim

RUN apt update && apt install -y wget

WORKDIR /opt

RUN wget https://github.com/kafbat/kafka-ui/releases/download/v1.4.2/api-v1.4.2.jar -O kafka-ui-api-v1.4.2.jar

RUN mkdir -p /opt/jks

COPY ./init-sh/kafka-ui-starter.sh /usr/bin

RUN chmod +x /usr/bin/kafka-ui-starter.sh 

CMD [ "kafka-ui-starter.sh" ]