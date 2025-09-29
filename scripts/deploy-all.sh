#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying complete MLOps Workshop infrastructure...${NC}"
echo ""

# Check if cluster exists
if ! kind get clusters | grep -q "mlops-workshop"; then
    echo -e "${YELLOW}Kind cluster not found. Creating cluster first...${NC}"
    bash scripts/setup-kind.sh
    echo ""
fi

# Validate cluster
echo -e "${BLUE}1. Validating cluster...${NC}"
bash scripts/validate-cluster.sh
echo ""

# Deploy MLflow
echo -e "${BLUE}2. Deploying MLflow...${NC}"
bash scripts/deploy-mlflow.sh
echo ""

# Deploy monitoring stack
echo -e "${BLUE}3. Deploying monitoring stack...${NC}"
bash scripts/deploy-monitoring.sh
echo ""

# Final status check
echo -e "${BLUE}4. Final infrastructure status...${NC}"
echo ""
echo -e "${GREEN}Cluster nodes:${NC}"
kubectl get nodes

echo ""
echo -e "${GREEN}All namespaces:${NC}"
kubectl get namespaces

echo ""
echo -e "${GREEN}All services:${NC}"
kubectl get svc -A

echo ""
echo -e "${GREEN}All ingresses:${NC}"
kubectl get ingress -A

echo ""
echo -e "${GREEN}🎉 Complete MLOps Workshop infrastructure deployed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Quick Access Guide:${NC}"
echo "================================"
echo "MLflow UI:      http://localhost:5000/mlflow"
echo "Prometheus:     http://localhost:9090/prometheus"  
echo "Grafana:        http://localhost:3000/grafana (admin/admin)"
echo ""
echo -e "${YELLOW}🔧 Port Forwarding Commands:${NC}"
echo "kubectl port-forward svc/mlflow-service 5000:5000 -n mlflow"
echo "kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring"
echo "kubectl port-forward svc/grafana-service 3000:3000 -n monitoring"
echo ""
echo -e "${YELLOW}📚 Next Steps:${NC}"
echo "1. Open workshop modules in the 'modules/' directory"
echo "2. Start with Module 1: Model Development"
echo "3. Use the deployed infrastructure for hands-on exercises"
echo ""
echo -e "${GREEN}Happy learning! 🎓${NC}"