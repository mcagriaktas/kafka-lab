FROM openjdk:17-slim-bullseye

ENV CONFLUENT_KAFKA_VERSION=8.0.0
ENV SCHEMA_REGISTRY_HOME=/opt/schema-registry
ENV SCHEMA_REGISTRY_DATA_HOME=/opt/data/schema-registry

RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/data/schema-registry /opt/schema-registry

RUN wget https://packages.confluent.io/archive/8.0/confluent-community-8.0.0.tar.gz -O /tmp/confluent.tar.gz && \
    tar -xvzf /tmp/confluent.tar.gz -C /opt && \
    mv /opt/confluent-${CONFLUENT_KAFKA_VERSION}/* ${SCHEMA_REGISTRY_HOME} && \
    rm -rf /opt/confluent-${CONFLUENT_KAFKA_VERSION} && \
    rm -rf /tmp/confluent.tar.gz

COPY init-sh/schema-registry-starter.sh /usr/bin/schema-registry-starter.sh
RUN chmod +x /usr/bin/schema-registry-starter.sh

WORKDIR ${SCHEMA_REGISTRY_HOME}

CMD [ "schema-registry-starter.sh" ]