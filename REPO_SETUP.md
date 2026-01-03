# Repository Setup Instructions

## 1. Setup Your Repository
- Repository name: `capsproject` ✅
- Clone your repository

## 2. Clone and Setup
```bash
git clone https://github.com/YOUR_USERNAME/capsproject.git
cd capsproject

# Copy all infrastructure code
cp -r /path/to/ass1-3/* .

# Clone the application code
git clone https://github.com/mdarifahammedreza/Ostad-Docker.git temp-app
cp -r temp-app/frontend .
cp -r temp-app/backend .
rm -rf temp-app

# Your final structure should be:
# ├── terraform/          # Infrastructure
# ├── k8s/               # Kubernetes manifests  
# ├── argocd/            # ArgoCD configs
# ├── .github/workflows/ # CI/CD pipeline
# ├── scripts/           # Setup scripts
# ├── frontend/          # React app
# └── backend/           # Node.js API
```

## 3. Update ArgoCD Application
```bash
# Edit argocd/application.yaml
# Change repoURL to: https://github.com/YOUR_USERNAME/capsproject.git
```

## 4. Configure GitHub Secrets
Go to: Repository Settings > Secrets and variables > Actions
Add:
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password/token

## 5. Push and Test
```bash
git add .
git commit -m "Initial 3-tier application setup"
git push origin main
```

This will trigger the GitHub Actions pipeline and test the complete flow.