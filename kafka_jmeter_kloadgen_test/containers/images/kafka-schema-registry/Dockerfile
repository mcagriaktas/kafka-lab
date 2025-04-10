FROM openjdk:17-slim-bullseye

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/schema-registry

RUN curl -SL "https://packages.confluent.io/archive/7.8/confluent-community-7.8.0.tar.gz" \
    -o /tmp/confluent.tar.gz

RUN tar -xzf /tmp/confluent.tar.gz -C /opt && \
    mv /opt/confluent-7.8.0/* /opt/schema-registry/ && \
    rm -rf /opt/confluent-7.8.0 && \
    rm /tmp/confluent.tar.gz
    
ENV SCHEMA_REGISTRY_HOME=/opt/schema-registry
RUN mkdir -p /data/schema-registry

COPY init-sh/schema-registry-starter.sh /opt/schema-registry/bin/schema-registry-starter.sh
RUN chmod +x /opt/schema-registry/bin/schema-registry-starter.sh

WORKDIR /opt/schema-registry/bin

CMD ["/opt/schema-registry/bin/schema-registry-starter.sh"]