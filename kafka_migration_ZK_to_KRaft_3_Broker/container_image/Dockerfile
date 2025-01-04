FROM ubuntu:24.10

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    nano \
    procps \
    wget \
    net-tools \
    python3 \
    python3-pip \
    ncurses-bin \
    lsof \
    openjdk-17-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN mkdir -p /mnt/all_logs/kafka
RUN mkdir -p /mnt/all_logs/kafka2

WORKDIR /mnt

RUN wget https://downloads.apache.org/zookeeper/zookeeper-3.7.2/apache-zookeeper-3.7.2-bin.tar.gz && \
    tar -xzf apache-zookeeper-3.7.2-bin.tar.gz && \
    rm apache-zookeeper-3.7.2-bin.tar.gz

RUN wget https://downloads.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz && \
    tar -xzf kafka_2.13-3.8.0.tgz && \
    rm kafka_2.13-3.8.0.tgz

RUN chmod 777 -R /mnt

CMD ["/bin/sh"]