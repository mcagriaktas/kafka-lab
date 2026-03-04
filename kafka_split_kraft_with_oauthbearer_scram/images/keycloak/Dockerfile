FROM openjdk:17.0.2-slim-bullseye

ENV KEYCLOAK_VERSION=26.5.4
ENV KEYCLOAK_HOME=/opt/keycloak
ENV KEYCLOAK_ADMIN=cagri
ENV KEYCLOAK_ADMIN_PASSWORD=cagri3541

RUN apt-get -y update && apt-get -y install tar gzip curl jq && apt-get clean all

WORKDIR /opt

RUN curl -fsSL https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz \
    | tar -xz && \
    mv keycloak-${KEYCLOAK_VERSION} keycloak

COPY init-sh/keycloak-starter.sh /usr/bin/keycloak-starter.sh
COPY init-sh/kafka-token-creater.sh /usr/bin/kafka-token-creater.sh
RUN chmod +x /usr/bin/keycloak-starter.sh
RUN chmod +x /usr/bin/kafka-token-creater.sh

EXPOSE 8080

CMD ["keycloak-starter.sh"]