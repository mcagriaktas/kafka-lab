FROM openjdk:26-ea-17-slim

ENV ZOOKEEPER_HOME=/opt/zookeeper
ENV ZOOKEEPER_DATA_HOME=/opt/data/zookeeper
ENV ZOOKEEPER_DATA_LOGS_HOME=/opt/data/zookeeper_logs
ENV ZOOKEEPER_VERSION=3.9.3

RUN apt-get update && \
    apt-get install -y \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN mkdir -p ${ZOOKEEPER_HOME} && \
    mkdir -p ${ZOOKEEPER_DATA_HOME}

WORKDIR /opt

RUN wget https://downloads.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz && \
    tar -xzf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz && \
    mv apache-zookeeper-${ZOOKEEPER_VERSION}-bin/* ${ZOOKEEPER_HOME} && \
    rm -rf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz && \
    rm -rf apache-zookeeper-${ZOOKEEPER_VERSION}-bin

COPY init-sh/zookeeper-starter.sh /usr/bin
RUN chmod +x /usr/bin/zookeeper-starter.sh

RUN chmod 777 -R /opt

CMD [ "zookeeper-starter.sh" ]