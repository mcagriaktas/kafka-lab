FROM openjdk:17-jdk-slim

RUN apt update && apt install -y wget

WORKDIR /opt

RUN wget https://github.com/provectus/kafka-ui/releases/download/v0.7.2/kafka-ui-api-v0.7.2.jar

COPY init-sh/starter-kafka-ui.sh /usr/bin/

RUN chmod +x /usr/bin/starter-kafka-ui.sh 

CMD [ "starter-kafka-ui.sh" ]