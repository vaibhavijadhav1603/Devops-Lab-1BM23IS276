# Jenkins image with docker CLI and pipeline plugins (the plain jenkins/jenkins:lts has no docker command)
FROM jenkins/jenkins:lts
USER root
COPY --from=docker:27.3.1-cli /usr/local/bin/docker /usr/local/bin/docker
USER jenkins
RUN jenkins-plugin-cli --plugins workflow-aggregator
