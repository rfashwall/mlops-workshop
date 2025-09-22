FROM mcr.microsoft.com/devcontainers/python:1-3.11-bullseye

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        wget \
        git \
        build-essential \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
        apt-transport-https \
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
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
    && apt-get update \
    && apt-get install helm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install terraform \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch to vscode user for Python package installations
USER vscode

# Install Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install --user -r /tmp/requirements.txt

# Install additional ML tools
RUN pip install --user \
    bentoml \
    kubeflow-pipelines \
    kfp \
    prometheus-client \
    grafana-api \
    onnx \
    onnxruntime \
    tensorrt \
    tritonclient[all]

# Set up Jupyter Lab
RUN pip install --user jupyterlab jupyterlab-git

# Create workspace directories
RUN mkdir -p /home/vscode/workspace

# Set working directory
WORKDIR /home/vscode/workspace

# Expose common ports
EXPOSE 3000 5000 8080 8888 9090 9091

# Set environment variables
ENV PATH="/home/vscode/.local/bin:${PATH}"
ENV PYTHONPATH="/home/vscode/workspace:${PYTHONPATH}"