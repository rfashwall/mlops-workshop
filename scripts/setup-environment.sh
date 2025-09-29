#!/bin/bash

# MLOps Workshop Environment Setup Script
set -e

echo "🚀 Setting up MLOps Workshop environment..."

# Create necessary directories if they don't exist
mkdir -p ~/.kube
mkdir -p ~/.docker
mkdir -p ~/workspace/data
mkdir -p ~/workspace/models
mkdir -p ~/workspace/logs

# Set up Git configuration (if not already set)
if [ -z "$(git config --global user.name)" ]; then
    echo "⚙️  Setting up Git configuration..."
    git config --global user.name "Workshop Participant"
    git config --global user.email "participant@mlops-workshop.local"
fi

# Initialize Git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial workshop setup"
fi

# Create initial checkpoint branches
echo "🌿 Creating checkpoint branches..."
if [ -f "scripts/create-checkpoints.sh" ]; then
    bash scripts/create-checkpoints.sh
else
    echo "ℹ️  Checkpoint script not found, skipping checkpoint creation"
fi

# Set up Kind cluster configuration
echo "🐳 Preparing Kind cluster configuration..."
if [ ! -f "configs/kind-config.yaml" ]; then
    cat > configs/kind-config.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: mlops-workshop
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
  - containerPort: 30001
    hostPort: 30001
    protocol: TCP
EOF
fi

# Create environment validation script
echo "✅ Creating environment validation script..."
cat > scripts/validate-environment.sh << 'EOF'
#!/bin/bash

echo "🔍 Validating MLOps Workshop environment..."

# Check Python and packages
echo "Checking Python environment..."
python --version
pip list | grep -E "(mlflow|bentoml|transformers|torch)" || echo "⚠️  Some Python packages may be missing"

# Check Docker
echo "Checking Docker..."
docker --version || echo "❌ Docker not available"

# Check Kubernetes tools
echo "Checking Kubernetes tools..."
kubectl version --client || echo "❌ kubectl not available"
kind version || echo "❌ Kind not available"
helm version || echo "❌ Helm not available"

# Check if Kind cluster exists
if kind get clusters | grep -q "mlops-workshop"; then
    echo "✅ Kind cluster 'mlops-workshop' exists"
else
    echo "ℹ️  Kind cluster not yet created (run scripts/setup-kind.sh)"
fi

echo "🎉 Environment validation complete!"
EOF

chmod +x scripts/validate-environment.sh

# Create participant environment validation script
echo "👥 Creating participant environment validation script..."
cat > scripts/validate-participant-env.sh << 'EOF'
#!/bin/bash

echo "🧑‍🎓 Validating participant environment..."

# Check if all required directories exist
REQUIRED_DIRS=("modules" "scripts" "configs" "wiki" "instructor" "tests")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ Directory $dir exists"
    else
        echo "❌ Directory $dir missing"
        exit 1
    fi
done

# Check if devcontainer is properly configured
if [ -f ".devcontainer/devcontainer.json" ] && [ -f ".devcontainer/Dockerfile" ]; then
    echo "✅ Devcontainer configuration found"
else
    echo "❌ Devcontainer configuration missing"
    exit 1
fi

# Check if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "✅ Requirements file found"
else
    echo "❌ Requirements file missing"
    exit 1
fi

# Validate Python environment
python -c "import mlflow, bentoml, transformers, torch" 2>/dev/null && echo "✅ Core ML packages available" || echo "⚠️  Some core ML packages may not be installed"

echo "🎉 Participant environment validation complete!"
EOF

chmod +x scripts/validate-participant-env.sh

# Run environment validation
echo "🔍 Running initial environment validation..."
bash scripts/validate-environment.sh

echo "✅ MLOps Workshop environment setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Run 'bash scripts/setup-kind.sh' to create the Kubernetes cluster"
echo "2. Open any module notebook to start the workshop"
echo "3. Use 'bash scripts/validate-participant-env.sh' to validate your setup"
echo ""
echo "📚 Workshop modules available in the 'modules/' directory"
echo "📖 Documentation available in the 'wiki/' directory"