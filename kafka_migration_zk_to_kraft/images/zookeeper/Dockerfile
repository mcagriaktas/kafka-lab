FROM ubuntu:24.10

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
    
RUN mkdir -p /mnt/all_logs/zookeeper_data

WORKDIR /mnt

RUN wget https://downloads.apache.org/zookeeper/zookeeper-3.7.2/apache-zookeeper-3.7.2-bin.tar.gz && \
    tar -xzf apache-zookeeper-3.7.2-bin.tar.gz && \
    rm apache-zookeeper-3.7.2-bin.tar.gz

COPY init-sh/zookeeper-starter.sh /usr/bin
RUN chmod +x /usr/bin/zookeeper-starter.sh

RUN chmod 777 -R /mnt

CMD [ "zookeeper-starter.sh" ]