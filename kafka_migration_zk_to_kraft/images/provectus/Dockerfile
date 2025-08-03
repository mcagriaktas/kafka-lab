FROM openjdk:17-jdk-slim

RUN apt update && apt install -y wget

WORKDIR /mnt

RUN wget https://github.com/provectus/kafka-ui/releases/download/v0.7.2/kafka-ui-api-v0.7.2.jar

COPY ./init-sh/kafka-ui-starter.sh /usr/bin

RUN chmod +x /usr/bin/kafka-ui-starter.sh 

CMD ["kafka-ui-starter.sh"]