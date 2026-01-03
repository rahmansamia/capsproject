# 3-Tier Application Infrastructure Assignment

## Architecture Overview
- **Frontend**: React/Vue SPA behind ALB in public subnet
- **Backend**: API server behind ALB in private subnet  
- **Database**: AWS RDS in private subnet
- **Kubernetes**: Self-hosted cluster on EC2 instances
- **CI/CD**: GitHub Actions + ArgoCD

## Project Structure
```
├── terraform/           # Infrastructure as Code
├── k8s/                # Kubernetes manifests
├── argocd/             # ArgoCD configurations
├── .github/workflows/  # CI/CD pipelines
└── scripts/            # User data scripts
```

## Deployment Steps
1. Deploy infrastructure with Terraform
2. Configure Kubernetes cluster
3. Setup ArgoCD
4. Configure CI/CD pipeline
5. Deploy applications

## Verification Steps
- [ ] Infrastructure deployed
- [ ] K8s cluster accessible via bastion
- [ ] ArgoCD dashboard accessible
- [ ] Applications deployed and accessible
- [ ] CI/CD pipeline working