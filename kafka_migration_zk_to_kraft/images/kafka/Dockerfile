FROM ubuntu:25.10

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
    
RUN mkdir -p /mnt/all_logs/kafka_data
RUN mkdir -p /mnt/all_logs/controller_data

WORKDIR /mnt

RUN wget https://downloads.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz && \
    tar -xzf kafka_2.13-3.8.0.tgz && \
    rm kafka_2.13-3.8.0.tgz

COPY init-sh/kafka-starter.sh /usr/bin
RUN chmod +x /usr/bin/kafka-starter.sh

RUN chmod 777 -R /mnt

CMD [ "kafka-starter.sh" ]