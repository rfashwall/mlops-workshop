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

# Install Kind (Kubernetes in Docker)
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 \
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

# Install core Python packages first
RUN pip install --user --no-cache-dir \
    numpy==1.24.4 \
    pandas==2.0.3 \
    matplotlib==3.7.2 \
    scikit-learn==1.3.2 \
    jupyter==1.0.0 \
    jupyterlab==4.0.9 \
    fastapi==0.104.1 \
    uvicorn==0.24.0 \
    requests==2.31.0

# Install ML packages
RUN pip install --user --no-cache-dir \
    torch==2.1.2 \
    transformers==4.36.2 \
    mlflow==2.8.1 \
    prometheus-client==0.19.0

# Install Kubernetes client
RUN pip install --user --no-cache-dir \
    kubernetes==28.1.0 \
    pyyaml==6.0.1

# Create workspace directories
RUN mkdir -p /home/vscode/workspace

# Set working directory
WORKDIR /home/vscode/workspace

# Expose common ports
EXPOSE 3000 5000 8080 8888 9090 9091

# Set environment variables
ENV PATH="/home/vscode/.local/bin:${PATH}"
ENV PYTHON_PATH="/home/vscode/workspace:${PYTHON_PATH}"