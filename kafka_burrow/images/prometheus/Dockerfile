FROM ubuntu:22.04

ENV PROMETHEUS_VERSION=2.45.0
ENV PROMETHEUS_HOME=/opt/prometheus

RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && tar xvfz prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64 ${PROMETHEUS_HOME} \
    && rm prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

WORKDIR ${PROMETHEUS_HOME}

COPY init-sh/prometheus-starter.sh /usr/bin/
RUN chmod +x /usr/bin/prometheus-starter.sh

CMD [ "prometheus-starter.sh" ]