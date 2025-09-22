#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="mlops-workshop"
CONFIG_FILE="configs/kind-config.yaml"
TIMEOUT=300

echo -e "${GREEN}Setting up Kind cluster for MLOps Workshop...${NC}"

# Check if Kind is installed
if ! command -v kind &> /dev/null; then
    echo -e "${RED}Error: Kind is not installed. Please install Kind first.${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Check if cluster already exists
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo -e "${YELLOW}Cluster '${CLUSTER_NAME}' already exists. Deleting...${NC}"
    kind delete cluster --name "${CLUSTER_NAME}"
fi

# Create the cluster
echo -e "${GREEN}Creating Kind cluster with configuration...${NC}"
if [ -f "${CONFIG_FILE}" ]; then
    kind create cluster --name "${CLUSTER_NAME}" --config "${CONFIG_FILE}" --wait "${TIMEOUT}s"
else
    echo -e "${RED}Error: Configuration file ${CONFIG_FILE} not found.${NC}"
    exit 1
fi

# Set kubectl context
echo -e "${GREEN}Setting kubectl context...${NC}"
kubectl cluster-info --context "kind-${CLUSTER_NAME}"

# Install NGINX Ingress Controller
echo -e "${GREEN}Installing NGINX Ingress Controller...${NC}"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo -e "${GREEN}Waiting for ingress controller to be ready...${NC}"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Create namespaces for workshop components
echo -e "${GREEN}Creating workshop namespaces...${NC}"
kubectl create namespace mlflow --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace workshop --dry-run=client -o yaml | kubectl apply -f -

# Label nodes for workshop workloads
echo -e "${GREEN}Labeling nodes for workshop workloads...${NC}"
kubectl label nodes --all workshop=enabled --overwrite

echo -e "${GREEN}Kind cluster setup completed successfully!${NC}"
echo -e "${YELLOW}Cluster name: ${CLUSTER_NAME}${NC}"
echo -e "${YELLOW}Context: kind-${CLUSTER_NAME}${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Run './scripts/validate-cluster.sh' to validate the setup"
echo "2. Deploy MLflow and monitoring components"
echo "3. Start the workshop exercises"