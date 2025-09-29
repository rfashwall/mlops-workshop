#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Deploying monitoring stack to Kubernetes...${NC}"

# Check if kubectl is available and cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    echo "Please ensure your Kind cluster is running: ./scripts/setup-kind.sh"
    exit 1
fi

# Ensure monitoring namespace exists
echo -e "${GREEN}Creating monitoring namespace...${NC}"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Apply monitoring ConfigMaps first
echo -e "${GREEN}Creating monitoring configuration...${NC}"
kubectl apply -f configs/monitoring-configmap.yaml

# Apply Prometheus deployment (includes PVC, RBAC, deployment, service, ingress)
echo -e "${GREEN}Deploying Prometheus...${NC}"
kubectl apply -f configs/prometheus-deployment.yaml

# Wait for Prometheus PVC to be ready
echo -e "${GREEN}Waiting for Prometheus PVC to be ready...${NC}"
timeout 60s bash -c 'until kubectl get pvc -n monitoring prometheus-pvc -o jsonpath="{.status.phase}" | grep -q "Bound"; do echo "Waiting for prometheus-pvc..."; sleep 5; done' || {
    echo -e "${YELLOW}Warning: prometheus-pvc not bound yet, continuing anyway...${NC}"
}

# Apply Grafana deployment (includes PVC, deployment, service, ingress)
echo -e "${GREEN}Deploying Grafana...${NC}"
kubectl apply -f configs/grafana-deployment.yaml

# Wait for Grafana PVC to be ready
echo -e "${GREEN}Waiting for Grafana PVC to be ready...${NC}"
timeout 60s bash -c 'until kubectl get pvc -n monitoring grafana-pvc -o jsonpath="{.status.phase}" | grep -q "Bound"; do echo "Waiting for grafana-pvc..."; sleep 5; done' || {
    echo -e "${YELLOW}Warning: grafana-pvc not bound yet, continuing anyway...${NC}"
}

# Wait for deployments to be ready
echo -e "${GREEN}Waiting for Prometheus deployment to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring

echo -e "${GREEN}Waiting for Grafana deployment to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

# Show deployment status
echo -e "${GREEN}Monitoring stack deployment status:${NC}"
kubectl get pods,svc,ingress -n monitoring

echo ""
echo -e "${GREEN}✅ Monitoring stack deployment completed!${NC}"
echo ""
echo -e "${YELLOW}Access services:${NC}"
echo "- Prometheus: http://localhost:9090/prometheus"
echo "- Grafana: http://localhost:3000/grafana (admin/admin)"
echo ""
echo -e "${YELLOW}Add to /etc/hosts for domain access:${NC}"
echo "127.0.0.1 prometheus.local grafana.local"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "- Prometheus logs: kubectl logs -f deployment/prometheus -n monitoring"
echo "- Grafana logs: kubectl logs -f deployment/grafana -n monitoring"
echo "- Port forward Prometheus: kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring"
echo "- Port forward Grafana: kubectl port-forward svc/grafana-service 3000:3000 -n monitoring"