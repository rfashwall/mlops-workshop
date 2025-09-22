# MLOps Workshop

A comprehensive hands-on workshop for building production-ready ML systems using industry-standard MLOps tools and practices.

## 🚀 Quick Start

### Using GitHub Codespaces (Recommended)

1. Click "Code" → "Codespaces" → "Create codespace on main"
2. Wait for the environment to set up automatically
3. Run `bash scripts/validate-participant-env.sh` to verify your setup
4. Start with Module 1 in the `modules/module1/` directory

### Local Development

1. Clone this repository
2. Install Docker and ensure it's running
3. Open in VS Code with Dev Containers extension
4. VS Code will prompt to reopen in container - click "Reopen in Container"

## 📚 Workshop Structure

### Modules (3 hours total)

- **Module 1**: Model Management and Versioning (30 min)
- **Module 2**: Production Deployment Patterns (30 min)  
- **Module 3**: Monitoring and Observability (30 min)
- **Module 4**: Pipeline Orchestration (30 min)
- **Module 5**: Model Optimization (30 min)
- **Module 6**: Real-World Integration (30 min)

### Directory Structure

```
mlops-workshop/
├── .devcontainer/          # GitHub Codespaces configuration
├── modules/                # Workshop modules (hands-on exercises)
│   ├── module1/           # Model Management and Versioning
│   ├── module2/           # Production Deployment
│   ├── module3/           # Monitoring and Observability
│   ├── module4/           # Pipeline Orchestration
│   ├── module5/           # Model Optimization
│   └── module6/           # Real-World Integration
├── scripts/               # Setup and utility scripts
├── configs/               # Configuration files for tools
├── wiki/                  # Documentation and guides
├── instructor/            # Instructor materials
└── tests/                 # Workshop validation tests
```

## 🛠️ Tools and Technologies

- **Model Management**: Hugging Face Hub, MLflow
- **Serving**: BentoML, Docker, Kubernetes
- **Monitoring**: Prometheus, Grafana
- **Orchestration**: Kubeflow, GitHub Actions
- **Optimization**: ONNX, TensorRT
- **Infrastructure**: Kind, Helm, Terraform

## 🎯 Learning Objectives

By the end of this workshop, you will be able to:

1. Version and manage ML models using modern tools
2. Deploy models to production with containerization
3. Monitor ML systems and detect issues early
4. Orchestrate ML pipelines with automation
5. Optimize models for production performance
6. Integrate all components into a complete MLOps system

## 📖 Getting Help

- Check the `wiki/` directory for detailed documentation
- Use `bash scripts/validate-environment.sh` to check your setup
- Each module has troubleshooting guides in `wiki/module-X-setup.md`

## 🌿 Checkpoint System

The workshop uses Git branches as checkpoints:

- `checkpoint-start` - Initial setup
- `checkpoint-moduleX-complete` - After completing each module
- `checkpoint-workshop-complete` - Final state

Use `bash scripts/switch-checkpoint.sh <checkpoint-name>` to jump to any checkpoint.

## 🤝 Contributing

This workshop is designed to be continuously improved. See `instructor/instructor-guide.md` for contribution guidelines.

---

**Ready to start?** Open `modules/module1/module1_model_management.ipynb` and begin your MLOps journey! 🚀