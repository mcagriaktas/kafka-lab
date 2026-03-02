FROM rockylinux:9.3

ENV KROXY_HOME=/opt/kroxy

RUN dnf update -y && \
    dnf install -y java-17-openjdk procps tar && \
    dnf clean all

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

RUN curl -L https://github.com/kroxylicious/kroxylicious/releases/download/v0.18.0/kroxylicious-app-0.18.0-bin.tar.gz -o /tmp/kroxy.tar.gz && \
    tar -xvf /tmp/kroxy.tar.gz -C /opt && \
    mv /opt/kroxylicious-app-0.18.0 ${KROXY_HOME} && \
    rm /tmp/kroxy.tar.gz

COPY ./init-sh/kroxy-starter.sh /usr/bin/kroxy-starter.sh
RUN chmod +x /usr/bin/kroxy-starter.sh

WORKDIR ${KROXY_HOME}

CMD [ "kroxy-starter.sh" ]