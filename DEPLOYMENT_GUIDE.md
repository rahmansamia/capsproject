# 3-Tier Application Deployment Guide

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** installed (v1.0+)
4. **SSH Key Pair** created in AWS
5. **GitHub Account** for CI/CD
6. **Docker Hub Account** for image registry

## Step-by-Step Deployment

### 1. Infrastructure Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd ass1-3

# Configure Terraform variables
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your values:
# - key_name: Your AWS key pair name
# - db_password: Secure database password
```

### 2. Deploy Infrastructure

```bash
# Make scripts executable (Linux/Mac)
chmod +x deploy.sh verify.sh

# Deploy infrastructure
./deploy.sh
```

### 3. Verify Deployment

```bash
# Check deployment status
./verify.sh
```

### 4. Access Kubernetes Cluster

```bash
# Get connection details
cd terraform
BASTION_IP=$(terraform output -raw bastion_public_ip)
MASTER_IP=$(terraform output -raw k8s_master_private_ip)

# SSH to bastion host
ssh -i your-key.pem ubuntu@$BASTION_IP

# From bastion, SSH to K8s master
ssh ubuntu@$MASTER_IP

# Check cluster status
kubectl get nodes
kubectl get pods -A
```

### 5. Setup ArgoCD

```bash
# On K8s master node, get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward ArgoCD (from bastion host)
kubectl port-forward svc/argocd-server-nodeport -n argocd 8080:80 --address 0.0.0.0

# Access ArgoCD UI at: http://BASTION_IP:8080
# Username: admin
# Password: (from above command)
```

### 6. Configure GitHub Repository

```bash
# Fork the application repository
# https://github.com/mdarifahammedreza/Ostad-Docker

# Add your repository URL to argocd/application.yaml
# Update the repoURL field with your forked repository

# Apply ArgoCD application
kubectl apply -f argocd/application.yaml
```

### 7. Setup CI/CD Pipeline

1. **Add Docker Hub secrets to GitHub:**
   - Go to your repository Settings > Secrets and variables > Actions
   - Add `DOCKER_USERNAME` and `DOCKER_PASSWORD`

2. **Push changes to trigger pipeline:**
   ```bash
   git add .
   git commit -m "Initial deployment"
   git push origin main
   ```

## Verification Checklist

### Infrastructure Verification
- [ ] VPC created with public/private subnets
- [ ] EC2 instances running in private subnets
- [ ] Bastion host accessible from internet
- [ ] RDS database in private subnet
- [ ] Load balancer in public subnet
- [ ] Security groups properly configured

### Kubernetes Verification
```bash
# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check ArgoCD
kubectl get pods -n argocd

# Check application namespace
kubectl get pods -n app
```

### Application Verification
```bash
# Check services
kubectl get svc -n app

# Check deployments
kubectl get deployments -n app

# Test NodePort services
curl http://WORKER_NODE_IP:30080  # Frontend
curl http://WORKER_NODE_IP:30081/api/health  # Backend
```

### Load Balancer Verification
```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test frontend
curl http://$ALB_DNS

# Test backend API
curl http://$ALB_DNS/api/health
```

## Troubleshooting

### Common Issues

1. **Instances not joining cluster:**
   ```bash
   # On master node, regenerate join command
   kubeadm token create --print-join-command
   
   # On worker nodes, run the join command
   sudo kubeadm join ...
   ```

2. **ArgoCD not accessible:**
   ```bash
   # Check ArgoCD pods
   kubectl get pods -n argocd
   
   # Restart ArgoCD server
   kubectl rollout restart deployment argocd-server -n argocd
   ```

3. **Applications not deploying:**
   ```bash
   # Check ArgoCD application status
   kubectl get applications -n argocd
   
   # Check application logs
   kubectl logs -n argocd deployment/argocd-application-controller
   ```

## Architecture Validation

### Network Security
- ✅ Frontend/Backend in private subnets
- ✅ Database in private subnet
- ✅ Load balancer in public subnet
- ✅ Bastion host for secure access
- ✅ Security groups restrict access appropriately

### High Availability
- ✅ Multi-AZ deployment
- ✅ Load balancer distributes traffic
- ✅ Multiple worker nodes
- ✅ Database in separate subnet

### CI/CD Pipeline
- ✅ GitHub Actions builds and pushes images
- ✅ ArgoCD automatically syncs deployments
- ✅ Rolling updates with zero downtime

## Cleanup

```bash
# Destroy infrastructure
cd terraform
terraform destroy -auto-approve
```

## Assignment Completion

Your assignment is complete when:
1. All infrastructure is deployed via Terraform
2. Kubernetes cluster is running on EC2 instances
3. ArgoCD is managing application deployments
4. CI/CD pipeline is functional
5. Applications are accessible via load balancer
6. All components are in correct network tiers
7. Security groups properly restrict access