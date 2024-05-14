#
# Cloudresty - aws-kubectl
#

# Base image
FROM    debian:bullseye-20240513-slim

# Image details
LABEL   org.opencontainers.image.authors="Cloudresty" \
        org.opencontainers.image.url="https://hub.docker.com/r/cloudresty/aws-kubectl" \
        org.opencontainers.image.source="https://github.com/cloudresty/aws-kubectl" \
        org.opencontainers.image.version="1.0.0" \
        org.opencontainers.image.revision="1.0.0" \
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
        ./aws/install

# Install kubectl (v1.26.0)
RUN     curl -LO https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl && \
        chmod +x ./kubectl && \
        mv ./kubectl /usr/local/bin/kubectl
