FROM rockylinux:9.3

WORKDIR /mnt
RUN chmod 755 /mnt

RUN dnf update -y && \
    dnf install -y --allowerasing \
        krb5-workstation \
        python3 \
        python3-pip \
        wget \
        curl \
        gnupg2 \
        vim \
        bind-utils \
        ca-certificates \
        gzip \
        tar \
        java-17-openjdk \
        java-17-openjdk-devel \
        dotnet-sdk-8.0 \
        procps \
        cyrus-sasl-gssapi && \
    dnf clean all

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

RUN curl -fL "https://github.com/VirtusLab/scala-cli/releases/latest/download/scala-cli-x86_64-pc-linux-static.gz" | \
    gunzip -c > /usr/local/bin/scala-cli && \
    chmod +x /usr/local/bin/scala-cli

COPY config/python_requirements.txt .
RUN pip3 install --no-cache-dir -r python_requirements.txt

COPY config/krb5.conf /etc/krb5.conf
COPY init-sh/starter-client.sh /usr/bin/starter-client.sh
RUN chmod 644 /etc/krb5.conf && \
    chmod +x /usr/bin/starter-client.sh

CMD [ "starter-client.sh" ]