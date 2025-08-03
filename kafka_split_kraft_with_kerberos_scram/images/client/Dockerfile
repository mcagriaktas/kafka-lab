FROM openjdk:17.0.1-jdk-slim

WORKDIR /mnt 
RUN chmod 777 -R /mnt

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y \
    krb5-user \
    python3 \
    python3-pip \
    wget \
    vim \
    apt-transport-https \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y libsasl2-modules-gssapi-mit && \
    apt-get install -y dotnet-sdk-8.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY config/python_requirements.txt /mnt/python_requirements.txt
RUN pip3 install --no-cache-dir -r /mnt/python_requirements.txt

COPY config/krb5.conf /etc/krb5.conf
COPY init-sh/starter-client.sh /mnt/starter-client.sh
RUN chmod +x /mnt/starter-client.sh

RUN chmod 777 -R /mnt

CMD [ "/mnt/starter-client.sh" ]