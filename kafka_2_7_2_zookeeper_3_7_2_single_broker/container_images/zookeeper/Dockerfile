FROM openjdk:11-jre-slim

ENV ZOOKEEPER_VERSION=3.7.2
ENV ZOOKEEPER_HOME=/zookeeper
ENV PATH=$PATH:$ZOOKEEPER_HOME/bin

RUN apt-get update && apt-get install -y \
    wget \
    tar \
    netcat \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://downloads.apache.org/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz \
    && tar -xvzf apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz \
    && mv apache-zookeeper-$ZOOKEEPER_VERSION-bin /zookeeper \
    && rm apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz

WORKDIR /$ZOOKEEPER_HOME/bin

CMD ["zkServer.sh", "start-foreground"]