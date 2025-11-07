FROM ubuntu:25.04

RUN apt-get update && \
    apt-get install -y \
    nano \
    procps \
    wget \
    net-tools \
    git \
    ncurses-bin \
    lsof \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN mkdir -p /mnt/all_logs

COPY ./init-sh/machine-starter.sh /usr/bin/
RUN chmod +x /usr/bin/machine-starter.sh

WORKDIR /mnt

RUN chmod 777 -R /mnt

CMD [ "machine-starter.sh" ]