FROM rockylinux:9.3

ENV COREDNS_VERSION=1.11.1

RUN dnf update -y && \
    dnf install -y \
        wget \
        tar \
        bind-utils \
        net-tools \
        iproute \
        systemd \
        ca-certificates && \
    dnf clean all

RUN wget -O /tmp/coredns.tgz \
    "https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_amd64.tgz" && \
    tar -xzf /tmp/coredns.tgz -C /tmp && \
    mv /tmp/coredns /usr/local/bin/coredns && \
    chmod +x /usr/local/bin/coredns && \
    rm -f /tmp/coredns.tgz

COPY ./init-sh/coredns-starter.sh /usr/local/bin/coredns-starter.sh
RUN chmod +x /usr/local/bin/coredns-starter.sh

CMD [ "coredns-starter.sh" ]