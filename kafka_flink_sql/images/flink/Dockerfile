FROM openjdk:17-slim-bullseye

# Set Flink version (https://downloads.apache.org/flink/)
ENV FLINK_VERSION=2.0.0
ENV KAFKA_FLINK_VERSION=4.0.0-2.0
ENV FLINK_HOME=/opt/flink
ENV FLINK_LIB_HOME=${FLINK_HOME}/lib

RUN apt-get update && \
    apt-get install -y wget curl netcat procps net-tools iputils-ping && \
    rm -rf /var/lib/apt/lists/*

# Flink Binary 
RUN wget -P /opt https://downloads.apache.org/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_2.12.tgz && \
    tar -xzf /opt/flink-${FLINK_VERSION}-bin-scala_2.12.tgz -C /opt/ && \
    rm /opt/flink-${FLINK_VERSION}-bin-scala_2.12.tgz && \
    mv /opt/flink-${FLINK_VERSION} ${FLINK_HOME} && \
    mkdir ${FLINK_HOME}/catalog

# Flink Stream and SQL
RUN wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-streaming-java/${FLINK_VERSION}/flink-streaming-java-${FLINK_VERSION}.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-sql-client/${FLINK_VERSION}/flink-sql-client-${FLINK_VERSION}.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-sql-gateway/${FLINK_VERSION}/flink-sql-gateway-${FLINK_VERSION}.jar -P ${FLINK_LIB_HOME} && \ 
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-json/${FLINK_VERSION}/flink-json-${FLINK_VERSION}.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-connector-base/${FLINK_VERSION}/flink-connector-base-${FLINK_VERSION}.jar -P ${FLINK_LIB_HOME}

# Flink Kafka Connectors (FLINK 2.0)
RUN wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/${KAFKA_FLINK_VERSION}/flink-sql-connector-kafka-${KAFKA_FLINK_VERSION}.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/${KAFKA_FLINK_VERSION}/flink-connector-kafka-${KAFKA_FLINK_VERSION}.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/4.0.0/kafka-clients-4.0.0.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/com/google/guava/guava/33.4.8-jre/guava-33.4.8-jre.jar -P ${FLINK_LIB_HOME} 

# Flink Prometheus Connector and system metrics dependencies
RUN wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-metrics-prometheus/${FLINK_VERSION}/flink-metrics-prometheus-${FLINK_VERSION}.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/com/github/oshi/oshi-core/6.4.4/oshi-core-6.4.4.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.13.0/jna-5.13.0.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/net/java/dev/jna/jna-platform/5.13.0/jna-platform-5.13.0.jar -P ${FLINK_LIB_HOME} && \
    wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-metrics-jmx/1.20.0/flink-metrics-jmx-1.20.0.jar -P ${FLINK_LIB_HOME}

# RocksDB state backend
RUN wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-statebackend-rocksdb/${FLINK_VERSION}/flink-statebackend-rocksdb-${FLINK_VERSION}.jar -P ${FLINK_LIB_HOME}

RUN mkdir -p ${FLINK_HOME}/flink-state/flink-checkpoints && \
    mkdir -p ${FLINK_HOME}/flink-state/flink-savepoints && \
    mkdir -p ${FLINK_HOME}/sql_query_list && \
    chmod 777 -R ${FLINK_HOME}
    
RUN chmod 777 -R ${FLINK_HOME}
WORKDIR $FLINK_HOME

COPY init-sh/flink-starter.sh /usr/bin
RUN chmod +x /usr/bin/flink-starter.sh

ENTRYPOINT [ "flink-starter.sh" ]