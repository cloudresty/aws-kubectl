#
# Cloudresty - aws-kubectl
#

# Base image
FROM    debian:trixie-slim

# Image details
LABEL   org.opencontainers.image.authors="Cloudresty" \
        org.opencontainers.image.url="https://hub.docker.com/r/cloudresty/aws-kubectl" \
        org.opencontainers.image.source="https://github.com/cloudresty/aws-kubectl" \
        org.opencontainers.image.version="1.1.0" \
        org.opencontainers.image.revision="1.1.0" \
        org.opencontainers.image.vendor="Cloudresty" \
        org.opencontainers.image.licenses="MIT" \
        org.opencontainers.image.title="aws-kubectl" \
        org.opencontainers.image.description="AWS CLI and kubectl"

# Update and install packages
RUN     apt-get update && \
        apt-get install -y \
            curl \
            unzip && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Install AWS CLI (v2)
RUN     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install && \
        rm -rf awscliv2.zip aws

# Install kubectl (v1.30.2)
# Latest stable verion can be found at https://dl.k8s.io/release/stable.txt
RUN     curl -LO https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl && \
        chmod +x ./kubectl && \
        mv ./kubectl /usr/local/bin/kubectl
