FROM gradle:7.4.2-jdk11

ENV CRUISE_CONTROL_HOME=/opt/cruise-control
ENV KAFKA_HEAP_OPTS="-Xms2G -Xmx6G"

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/linkedin/cruise-control.git

RUN cd ${CRUISE_CONTROL_HOME} && ./gradlew jar copyDependantLibs

RUN mkdir ${CRUISE_CONTROL_HOME}/logs

COPY init-sh/cruis-control-starter.sh /usr/bin
RUN chmod +x /usr/bin/cruis-control-starter.sh

WORKDIR ${CRUISE_CONTROL_HOME}

CMD [ "cruis-control-starter.sh" ] 