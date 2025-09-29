#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Installing ML packages post-creation...${NC}"
echo "This may take a few minutes as we install PyTorch and other large packages."
echo ""

# Install core ML packages
echo -e "${GREEN}Installing core ML libraries...${NC}"
pip install --user --no-cache-dir \
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    seaborn

# Install PyTorch (CPU version to save space)
echo -e "${GREEN}Installing PyTorch (CPU version)...${NC}"
pip install --user --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install Transformers and HuggingFace
echo -e "${GREEN}Installing Transformers and HuggingFace libraries...${NC}"
pip install --user --no-cache-dir \
    transformers \
    datasets \
    huggingface-hub

# Install MLflow and MLOps tools
echo -e "${GREEN}Installing MLOps tools...${NC}"
pip install --user --no-cache-dir \
    mlflow \
    bentoml

# Install additional useful packages
echo -e "${GREEN}Installing additional packages...${NC}"
pip install --user --no-cache-dir \
    plotly \
    ipywidgets \
    black \
    pytest \
    python-dotenv \
    click \
    rich \
    tqdm

echo ""
echo -e "${GREEN}✅ ML packages installation completed!${NC}"
echo ""
echo -e "${YELLOW}Installed packages:${NC}"
echo "- NumPy, Pandas, Matplotlib, Scikit-learn"
echo "- PyTorch (CPU version)"
echo "- Transformers, Datasets, HuggingFace Hub"
echo "- MLflow, BentoML"
echo "- Jupyter, Plotly, and development tools"
echo ""
echo -e "${BLUE}You can now start using the MLOps workshop environment!${NC}"