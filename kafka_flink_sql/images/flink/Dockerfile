FROM openjdk:11-jre

# Set Flink version (https://downloads.apache.org/flink/)
ENV FLINK_VERSION=1.19.0
ENV SCALA_VERSION=2.12
ENV FLINK_CONNECTOR_KAFKA_VERSION=3.4.0

RUN apt-get update && \
    apt-get install -y wget tar && \
    rm -rf /var/lib/apt/lists/*

RUN wget -P /opt https://downloads.apache.org/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_${SCALA_VERSION}.tgz && \
    tar -xzf /opt/flink-${FLINK_VERSION}-bin-scala_${SCALA_VERSION}.tgz -C /opt/ && \
    rm /opt/flink-${FLINK_VERSION}-bin-scala_${SCALA_VERSION}.tgz && \
    mv /opt/flink-${FLINK_VERSION} /opt/flink && \
    mkdir /opt/flink/catalog

# Flink Kafka Connector (https://mvnrepository.com/artifact/org.apache.flink/flink-connector-kafka)
RUN wget https://downloads.apache.org/flink/flink-connector-kafka-${FLINK_CONNECTOR_KAFKA_VERSION}/flink-connector-kafka-${FLINK_CONNECTOR_KAFKA_VERSION}-src.tgz && \
    tar -xzf flink-connector-kafka-${FLINK_CONNECTOR_KAFKA_VERSION}-src.tgz -C /opt/flink/lib/ && \
    rm flink-connector-kafka-${FLINK_CONNECTOR_KAFKA_VERSION}-src.tgz

RUN wget -q https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.4.0/kafka-clients-3.4.0.jar -P /opt/flink/lib/ && \
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.3.0-1.19/flink-connector-kafka-3.3.0-1.19.jar -P /opt/flink/lib/ && \
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-streaming-scala_2.12/1.19.0/flink-streaming-scala_2.12-1.19.0.jar -P /opt/flink/lib/ && \
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-sql-client/1.19.0/flink-sql-client-1.19.0.jar -P /opt/flink/lib/ && \
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-sql-gateway/1.19.0/flink-sql-gateway-1.19.0.jar -P /opt/flink/opt/ && \ 
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.19.0/flink-json-1.19.0.jar -P /opt/flink/opt/

ENV FLINK_HOME=/opt/flink
ENV PATH=$PATH:$FLINK_HOME/bin
RUN chmod 777 -R /opt/flink

WORKDIR $FLINK_HOME

COPY init-sh/starter-flink.sh ./
RUN chmod +x starter-flink.sh

ENTRYPOINT ["./starter-flink.sh"]