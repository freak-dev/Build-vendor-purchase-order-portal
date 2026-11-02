FROM jenkins/jenkins:lts-jdk21

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends docker-cli git curl ca-certificates python3 python3-pip ansible \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/lib/docker/cli-plugins
COPY --chmod=0755 docker-compose /usr/local/lib/docker/cli-plugins/docker-compose
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /usr/share/jenkins/ref/casc.yaml
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

USER jenkins
