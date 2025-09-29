#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Deploying MLflow to Kubernetes...${NC}"

# Check if kubectl is available and cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    echo "Please ensure your Kind cluster is running: ./scripts/setup-kind.sh"
    exit 1
fi

# Ensure mlflow namespace exists
echo -e "${GREEN}Creating mlflow namespace...${NC}"
kubectl create namespace mlflow --dry-run=client -o yaml | kubectl apply -f -

# Apply PVCs first (they need to exist before deployments)
echo -e "${GREEN}Creating persistent volume claims...${NC}"
kubectl apply -f configs/mlflow-pvc.yaml

# Wait for PVCs to be bound (with timeout)
echo -e "${GREEN}Waiting for PVCs to be ready...${NC}"
timeout 60s bash -c 'until kubectl get pvc -n mlflow mlflow-pvc -o jsonpath="{.status.phase}" | grep -q "Bound"; do echo "Waiting for mlflow-pvc..."; sleep 5; done' || {
    echo -e "${YELLOW}Warning: mlflow-pvc not bound yet, continuing anyway...${NC}"
}

timeout 60s bash -c 'until kubectl get pvc -n mlflow mlflow-artifacts-pvc -o jsonpath="{.status.phase}" | grep -q "Bound"; do echo "Waiting for mlflow-artifacts-pvc..."; sleep 5; done' || {
    echo -e "${YELLOW}Warning: mlflow-artifacts-pvc not bound yet, continuing anyway...${NC}"
}

# Apply MLflow deployment
echo -e "${GREEN}Deploying MLflow server...${NC}"
kubectl apply -f configs/mlflow-deployment.yaml

# Apply MLflow service and ingress
echo -e "${GREEN}Creating MLflow service and ingress...${NC}"
kubectl apply -f configs/mlflow-service.yaml

# Wait for deployment to be ready
echo -e "${GREEN}Waiting for MLflow deployment to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/mlflow-server -n mlflow

# Show deployment status
echo -e "${GREEN}MLflow deployment status:${NC}"
kubectl get pods,svc,ingress -n mlflow

echo ""
echo -e "${GREEN}✅ MLflow deployment completed!${NC}"
echo ""
echo -e "${YELLOW}Access MLflow:${NC}"
echo "- Local: http://localhost:5000/mlflow"
echo "- Add to /etc/hosts: 127.0.0.1 mlflow.local"
echo "- Then access: http://mlflow.local"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "- Check logs: kubectl logs -f deployment/mlflow-server -n mlflow"
echo "- Port forward: kubectl port-forward svc/mlflow-service 5000:5000 -n mlflow"
echo "- Delete deployment: kubectl delete -f configs/mlflow-deployment.yaml"