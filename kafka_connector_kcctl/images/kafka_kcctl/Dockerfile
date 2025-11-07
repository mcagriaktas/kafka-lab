FROM ubuntu:25.04

ENV KAFKA_KCCTL_HOME=/opt/kafka_kcctl
ENV KAFKA_KCCTL_VERSION=1.0.0.CR4
ENV KCCTL_CONFIG_FILE=/opt/kafka_kcctl/kcctl-config.json

RUN apt update && apt install -y wget

WORKDIR /opt

RUN mkdir -p ${KAFKA_KCCTL_HOME}

RUN wget https://github.com/kcctl/kcctl/releases/download/v${KAFKA_KCCTL_VERSION}/kcctl-${KAFKA_KCCTL_VERSION}-linux-x86_64.tar.gz && \
    tar -xvf kcctl-${KAFKA_KCCTL_VERSION}-linux-x86_64.tar.gz && \
    cp -r kcctl-1.0.0.CR4-linux-x86_64/* ${KAFKA_KCCTL_HOME} && \
    rm -rf kcctl-1.0.0.CR4-linux-x86_64.tar.gz kcctl-1.0.0.CR4-linux-x86_64

COPY ./init-sh/kafka-kcctl-starter.sh /usr/bin

RUN chmod +x /usr/bin/kafka-kcctl-starter.sh

CMD [ "kafka-kcctl-starter.sh" ]