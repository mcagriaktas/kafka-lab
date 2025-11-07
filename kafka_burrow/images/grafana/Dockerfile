FROM ubuntu:25.04

ENV GRAFANA_VERSION=10.4.14
ENV GRAFANA_HOME=/opt/grafana
ENV ADMIN_USER=cagri
ENV ADMIN_PASSWORD=3541
ENV GF_SECURITY_ADMIN_USER="${ADMIN_USER}"
ENV GF_SECURITY_ADMIN_PASSWORD="${ADMIN_PASSWORD}"
ENV GF_PATHS_DATA="/opt/grafana/data"
ENV GF_PATHS_LOGS="/opt/grafana/logs"
ENV GF_PATHS_PROVISIONING="/opt/grafana/provisioning"

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    wget \
    gnupg2 \
    curl \
    jq \
    adduser \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key && \
    echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list && \
    apt-get update && \
    apt-get install -y grafana=${GRAFANA_VERSION} && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/grafana/plugins \
    /opt/grafana/provisioning/dashboards \
    /opt/grafana/provisioning/dashboards/json \
    /opt/grafana/provisioning/datasources \
    /opt/grafana/data \
    /opt/grafana/logs

RUN cp -r /usr/share/grafana/* /opt/grafana/.

WORKDIR ${GRAFANA_HOME}

COPY init-sh/grafana-starter.sh /usr/bin/grafana-starter.sh
RUN chmod +x /usr/bin/grafana-starter.sh

CMD [ "grafana-starter.sh" ]
