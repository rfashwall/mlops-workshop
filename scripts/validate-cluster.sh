#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="mlops-workshop"
REQUIRED_NAMESPACES=("mlflow" "monitoring" "workshop" "ingress-nginx")

echo -e "${BLUE}Validating Kind cluster setup for MLOps Workshop...${NC}"
echo ""

# Function to check command availability
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        return 1
    fi
}

# Function to validate cluster existence
validate_cluster() {
    if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        echo -e "${GREEN}✓${NC} Kind cluster '${CLUSTER_NAME}' exists"
        return 0
    else
        echo -e "${RED}✗${NC} Kind cluster '${CLUSTER_NAME}' not found"
        return 1
    fi
}

# Function to validate kubectl context
validate_context() {
    local current_context
    current_context=$(kubectl config current-context 2>/dev/null || echo "")
    
    if [ "$current_context" = "kind-${CLUSTER_NAME}" ]; then
        echo -e "${GREEN}✓${NC} kubectl context is set to 'kind-${CLUSTER_NAME}'"
        return 0
    else
        echo -e "${RED}✗${NC} kubectl context is not set correctly (current: $current_context)"
        return 1
    fi
}

# Function to validate cluster connectivity
validate_connectivity() {
    if kubectl cluster-info &> /dev/null; then
        echo -e "${GREEN}✓${NC} Cluster is accessible"
        return 0
    else
        echo -e "${RED}✗${NC} Cannot connect to cluster"
        return 1
    fi
}

# Function to validate nodes
validate_nodes() {
    local node_count
    local ready_nodes
    
    node_count=$(kubectl get nodes --no-headers | wc -l)
    ready_nodes=$(kubectl get nodes --no-headers | grep -c " Ready ")
    
    if [ "$node_count" -ge 3 ] && [ "$ready_nodes" -eq "$node_count" ]; then
        echo -e "${GREEN}✓${NC} All $node_count nodes are ready"
        return 0
    else
        echo -e "${RED}✗${NC} Node issues detected (Total: $node_count, Ready: $ready_nodes)"
        return 1
    fi
}

# Function to validate namespaces
validate_namespaces() {
    local failed=0
    
    for ns in "${REQUIRED_NAMESPACES[@]}"; do
        if kubectl get namespace "$ns" &> /dev/null; then
            echo -e "${GREEN}✓${NC} Namespace '$ns' exists"
        else
            echo -e "${RED}✗${NC} Namespace '$ns' missing"
            failed=1
        fi
    done
    
    return $failed
}

# Function to validate ingress controller
validate_ingress() {
    local ingress_ready
    
    ingress_ready=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller --no-headers 2>/dev/null | grep -c "Running" || echo "0")
    
    if [ "$ingress_ready" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} NGINX Ingress Controller is running"
        return 0
    else
        echo -e "${RED}✗${NC} NGINX Ingress Controller is not ready"
        return 1
    fi
}

# Function to validate port mappings
validate_ports() {
    local ports=("80" "443" "5004" "3000" "9090")
    local failed=0
    
    for port in "${ports[@]}"; do
        if docker port "${CLUSTER_NAME}-control-plane" | grep -q ":${port}->"; then
            echo -e "${GREEN}✓${NC} Port $port is mapped"
        else
            echo -e "${YELLOW}!${NC} Port $port mapping not found (may be normal)"
        fi
    done
    
    return 0
}

# Function to show cluster info
show_cluster_info() {
    echo ""
    echo -e "${BLUE}Cluster Information:${NC}"
    echo "==================="
    
    echo -e "${YELLOW}Cluster Name:${NC} $CLUSTER_NAME"
    echo -e "${YELLOW}Context:${NC} kind-$CLUSTER_NAME"
    
    echo ""
    echo -e "${YELLOW}Nodes:${NC}"
    kubectl get nodes -o wide
    
    echo ""
    echo -e "${YELLOW}Namespaces:${NC}"
    kubectl get namespaces
    
    echo ""
    echo -e "${YELLOW}System Pods:${NC}"
    kubectl get pods -A | grep -E "(kube-system|ingress-nginx)"
}

# Main validation
echo -e "${BLUE}1. Checking required tools...${NC}"
TOOLS_OK=0
check_command "kind" || TOOLS_OK=1
check_command "kubectl" || TOOLS_OK=1
check_command "docker" || TOOLS_OK=1

echo ""
echo -e "${BLUE}2. Validating cluster...${NC}"
CLUSTER_OK=0
validate_cluster || CLUSTER_OK=1
validate_context || CLUSTER_OK=1
validate_connectivity || CLUSTER_OK=1

echo ""
echo -e "${BLUE}3. Validating cluster components...${NC}"
COMPONENTS_OK=0
validate_nodes || COMPONENTS_OK=1
validate_namespaces || COMPONENTS_OK=1
validate_ingress || COMPONENTS_OK=1

echo ""
echo -e "${BLUE}4. Validating port mappings...${NC}"
validate_ports

# Show detailed info if validation passes
if [ $TOOLS_OK -eq 0 ] && [ $CLUSTER_OK -eq 0 ] && [ $COMPONENTS_OK -eq 0 ]; then
    show_cluster_info
fi

echo ""
echo -e "${BLUE}Validation Summary:${NC}"
echo "=================="

if [ $TOOLS_OK -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Required tools are available"
else
    echo -e "${RED}✗${NC} Some required tools are missing"
fi

if [ $CLUSTER_OK -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Cluster is properly configured"
else
    echo -e "${RED}✗${NC} Cluster configuration issues detected"
fi

if [ $COMPONENTS_OK -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All cluster components are ready"
else
    echo -e "${RED}✗${NC} Some cluster components have issues"
fi

echo ""
if [ $TOOLS_OK -eq 0 ] && [ $CLUSTER_OK -eq 0 ] && [ $COMPONENTS_OK -eq 0 ]; then
    echo -e "${GREEN}🎉 Cluster validation passed! Ready for MLOps workshop.${NC}"
    exit 0
else
    echo -e "${RED}❌ Cluster validation failed. Please check the issues above.${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting tips:${NC}"
    echo "- Run './scripts/setup-kind.sh' to recreate the cluster"
    echo "- Check Docker is running: 'docker info'"
    echo "- Verify Kind installation: 'kind version'"
    echo "- Check kubectl installation: 'kubectl version --client'"
    exit 1
fi