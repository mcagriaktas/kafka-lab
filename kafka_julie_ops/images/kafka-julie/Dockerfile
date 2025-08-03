FROM openjdk:11-jdk-slim

ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV JULIE_CONFIG_PATH="/opt/kafka_julie/config"
ENV JULIE_TOPOLOGY_PATH="/opt/kafka_julie/topology"
ENV JULIE_VERSION=4.4.1

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    unzip \
    bash \
    vim \
    python3 \
    python3-pip \
    procps \
    jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN mkdir -p /opt/kafka_julie /opt/ngrok_tunnel && \
    mkdir -p /opt/kafka_julie/config /opt/kafka_julie/topology /opt/kafka_julie/logs /opt/kafka_julie/git-repo

RUN wget https://oss.sonatype.org/service/local/repositories/releases/content/com/purbon/kafka/julie-ops/${JULIE_VERSION}/julie-ops-${JULIE_VERSION}.jar -P /opt/kafka_julie

RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -P /opt/ngrok_tunnel/ \
    && tar -xzf /opt/ngrok_tunnel/ngrok-v3-stable-linux-amd64.tgz -C /opt/ngrok_tunnel/ \
    && chmod +x /opt/ngrok_tunnel/ngrok \
    && rm /opt/ngrok_tunnel/ngrok-v3-stable-linux-amd64.tgz

COPY init-sh/kafka-julie-starter.sh /usr/bin/kafka-julie-starter.sh
COPY init-sh/webhook-listener.py /opt/kafka_julie/webhook-listener.py
COPY init-sh/ngrok.yaml /root/.config/ngrok_tunnel/ngrok.yml
# COPY init-sh/.gitignore /opt/kafka_julie/git-repo/.gitignore

RUN chmod +x /usr/bin/kafka-julie-starter.sh

CMD [ "kafka-julie-starter.sh" ]