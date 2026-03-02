FROM rockylinux:9.3

ENV HAPROXY_HOME=/opt/haproxy
ENV HAPROXY_VERSION=3.2.6

# Install dependencies
RUN dnf update -y && \
    dnf install -y gcc make openssl-devel pcre-devel systemd-devel tar wget zlib-devel && \
    dnf clean all

# Create haproxy user and group
RUN groupadd -r haproxy && \
    useradd -r -g haproxy -s /sbin/nologin -c "HAProxy user" haproxy

# Download and compile HAProxy
RUN mkdir -p ${HAPROXY_HOME} && \
    cd /opt && \
    wget https://www.haproxy.org/download/${HAPROXY_VERSION%.*}/src/haproxy-${HAPROXY_VERSION}.tar.gz -O haproxy-${HAPROXY_VERSION}.tar.gz && \
    tar -xzf haproxy-${HAPROXY_VERSION}.tar.gz && \
    cd haproxy-${HAPROXY_VERSION} && \
    make -j$(nproc) TARGET=linux-glibc \
        USE_OPENSSL=1 \
        USE_PCRE=1 \
        USE_ZLIB=1 \
        USE_SYSTEMD=1 \
        USE_LINUX_SPLICE=1 \
        USE_THREAD=1 && \
    make install PREFIX=/usr/local && \
    cd /opt && \
    rm -rf haproxy-${HAPROXY_VERSION} haproxy-${HAPROXY_VERSION}.tar.gz

# Create necessary directories
RUN mkdir -p ${HAPROXY_HOME}/configs && \
    mkdir -p /var/lib/haproxy && \
    mkdir -p /var/run/haproxy && \
    mkdir -p /usr/local/etc/haproxy/errors && \
    chown -R haproxy:haproxy ${HAPROXY_HOME} /var/lib/haproxy /var/run/haproxy

# Copy startup script
COPY ./init-sh/haproxy-starter.sh /usr/bin/haproxy-starter.sh
RUN chmod +x /usr/bin/haproxy-starter.sh

# Expose ports
EXPOSE 8080 8404

CMD ["haproxy-starter.sh"]