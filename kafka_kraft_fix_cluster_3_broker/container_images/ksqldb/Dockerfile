FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    openjdk-17-jdk \
    netcat \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/ksqldb \
    && mkdir -p /var/lib/ksqldb \
    && mkdir -p /etc/ksqldb

RUN wget https://packages.confluent.io/archive/7.8/confluent-7.8.0.tar.gz \
    && tar -xzf confluent-7.8.0.tar.gz -C /usr/share/ksqldb --strip-components=1 \
    && rm confluent-7.8.0.tar.gz

ENV PATH="/usr/share/ksqldb/bin:${PATH}"

COPY start-ksqldb.sh /usr/bin/
RUN chmod +x /usr/bin/start-ksqldb.sh

COPY server.properties /etc/ksqldb/

EXPOSE 8088

CMD ["start-ksqldb.sh"]