FROM mcr.microsoft.com/devcontainers/python:1-3.11-bullseye

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        wget \
        git \
        build-essential \
        ca-certificates \
        jq \
        vim \
        htop \
        tree \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Kind (Kubernetes in Docker) - Latest version
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64 \
    && chmod +x ./kind \
    && mv ./kind /usr/local/bin/kind

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh \
    && rm get_helm.sh

# Switch to vscode user for Python package installations
USER vscode

# Upgrade pip first
RUN pip install --user --upgrade pip setuptools wheel

# Install only essential lightweight packages during build
# Heavy ML packages will be installed post-creation to avoid disk space issues
RUN pip install --user --no-cache-dir \
    fastapi \
    uvicorn \
    requests \
    pyyaml \
    kubernetes \
    prometheus-client \
    jupyter \
    jupyterlab

# Create workspace directories
RUN mkdir -p /home/vscode/workspace

# Set working directory
WORKDIR /home/vscode/workspace

# Expose common ports
EXPOSE 3000 5000 8080 8888 9090 9091

# Set environment variables
ENV PATH="/home/vscode/.local/bin:${PATH}"
ENV PYTHONPATH="/home/vscode/workspace:${PYTHONPATH}"