FROM ubuntu:25.04

ENV PROMETHEUS_HOME=/opt/prometheus
ENV PROMETHEUS_VERSION=2.45.0

RUN apt-get update && apt-get install -y \
    wget curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $PROMETHEUS_HOME

RUN wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && tar xvfz prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/* ${PROMETHEUS_HOME}/ \
    && rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64*

WORKDIR /prometheus

COPY init-sh/prometheus-starter.sh /usr/bin/prometheus-starter.sh
RUN chmod +x /usr/bin/prometheus-starter.sh

CMD [ "prometheus-starter.sh" ]