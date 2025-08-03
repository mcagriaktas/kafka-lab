FROM openjdk:21-slim-bullseye

ENV JENKINS_HOME=/opt/jenkins
ENV JENKINS_VERSION=2.506
ENV KAFKA_VERSION=4.0.0
ENV FLINK_VERSION=2.0.0
ENV SCALA_VERSION=2.12

RUN apt-get update && \
    apt-get install -y \
    curl wget git openssh-client unzip \
    ca-certificates \
    sshpass \
    fontconfig libfreetype6 libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${JENKINS_HOME}/.ssh && \
    echo "StrictHostKeyChecking no" > ${JENKINS_HOME}/.ssh/config && \
    chmod 600 ${JENKINS_HOME}/.ssh/config

RUN mkdir -p /opt/kafka && \
    curl "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz" \
    -o /opt/kafka/kafka.tgz && \
    mkdir -p /opt/kafka/bin && \
    tar -xvzf /opt/kafka/kafka.tgz -C /opt/kafka --strip-components=1 && \
    rm /opt/kafka/kafka.tgz

RUN mkdir -p ${JENKINS_HOME} /usr/share/jenkins ${JENKINS_HOME}/init.groovy.d ${JENKINS_HOME}/groovys \
    ${JENKINS_HOME}/groovys_base /opt/jenkins/scripts

RUN curl -fL https://get.jenkins.io/war/${JENKINS_VERSION}/jenkins.war -o /usr/share/jenkins/jenkins.war || \
    curl -fL https://get.jenkins.io/war-stable/${JENKINS_VERSION}/jenkins.war -o /usr/share/jenkins/jenkins.war && \
    chmod 644 /usr/share/jenkins/jenkins.war

COPY init-sh/groovy/00-init-jobs.groovy ${JENKINS_HOME}/init.groovy.d/00-init-jobs.groovy
COPY init-sh/groovys_base ${JENKINS_HOME}/groovys_base

COPY init-sh/jenkins-starter.sh /usr/bin/
RUN chmod +x /usr/bin/jenkins-starter.sh

WORKDIR $JENKINS_HOME

ENTRYPOINT [ "jenkins-starter.sh" ]