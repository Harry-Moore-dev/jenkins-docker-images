FROM jenkins/agent:alpine

USER root

# Define variables
ARG VERSION=1.11.2
ENV JENKINS_HOME=/home/jenkins
LABEL org.opencontainers.image.source=https://github.com/Harry-Moore-dev/jenkins-docker-images
LABEL org.opencontainers.image.description="Jenkins agent with Terraform installed"

WORKDIR ${JENKINS_HOME}

# Install dependencies and Terraform
RUN apk add --update --virtual .deps --no-cache gnupg wget unzip \
    && cd /tmp \
    && wget https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip \
    && wget https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_SHA256SUMS \
    && wget https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_SHA256SUMS.sig \
    && wget -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import \
    && gpg --verify terraform_${VERSION}_SHA256SUMS.sig terraform_${VERSION}_SHA256SUMS \
    && grep terraform_${VERSION}_linux_amd64.zip terraform_${VERSION}_SHA256SUMS | sha256sum -c \
    && unzip /tmp/terraform_${VERSION}_linux_amd64.zip -d /tmp \
    && mv /tmp/terraform /usr/local/bin/terraform \
    && rm -f /tmp/terraform_${VERSION}_linux_amd64.zip /tmp/terraform_${VERSION}_SHA256SUMS /tmp/terraform_${VERSION}_SHA256SUMS.sig \
    && apk del .deps

USER jenkins

# Verify installation
RUN terraform --version