FROM openjdk:17-slim-bullseye

ENV KAFKA_CONFLUENT_MAJOR_VERSION=8.0
ENV KAFKA_CONFLUENT_MINOR_VERSION=${KAFKA_CONFLUENT_MAJOR_VERSION}.0
ENV KSQL_DIR=/opt/ksqldb

RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${KSQL_DIR}

RUN wget https://packages.confluent.io/archive/${KAFKA_CONFLUENT_MAJOR_VERSION}/confluent-${KAFKA_CONFLUENT_MINOR_VERSION}.tar.gz -O /tmp/ksqldb.tgz && \
    tar -xvzf /tmp/ksqldb.tgz -C /opt && \
    mv /opt/confluent-${KAFKA_CONFLUENT_MINOR_VERSION}/* ${KSQL_DIR} && \
    rm -rf /opt/confluent-${KAFKA_CONFLUENT_MINOR_VERSION}

RUN mkdir -p ${KSQL_DIR}/config

COPY init-sh/ksqldb-starter.sh /usr/bin/
RUN chmod +x /usr/bin/ksqldb-starter.sh

CMD [ "ksqldb-starter.sh" ]