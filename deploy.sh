#!/bin/bash

set -e

echo "🚀 Starting 3-Tier Application Deployment"

# Check if terraform.tfvars exists
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found!"
    echo "Please copy terraform/terraform.tfvars.example to terraform/terraform.tfvars and fill in your values"
    exit 1
fi

# Deploy infrastructure
echo "📦 Deploying infrastructure with Terraform..."
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

# Get outputs
BASTION_IP=$(terraform output -raw bastion_public_ip)
MASTER_IP=$(terraform output -raw k8s_master_private_ip)
ALB_DNS=$(terraform output -raw alb_dns_name)

echo "✅ Infrastructure deployed successfully!"
echo "🔗 Bastion Host IP: $BASTION_IP"
echo "🔗 K8s Master IP: $MASTER_IP"
echo "🔗 Application URL: http://$ALB_DNS"

cd ..

# Create connection script
cat > connect-to-cluster.sh << EOF
#!/bin/bash
echo "Connecting to Kubernetes cluster via bastion host..."
echo "1. SSH to bastion: ssh -i your-key.pem ubuntu@$BASTION_IP"
echo "2. From bastion, SSH to master: ssh ubuntu@$MASTER_IP"
echo "3. Check cluster status: kubectl get nodes"
echo "4. Access ArgoCD: kubectl port-forward svc/argocd-server-nodeport -n argocd 8080:80"
EOF

chmod +x connect-to-cluster.sh

echo "🎉 Deployment completed!"
echo "📋 Next steps:"
echo "   1. Wait 5-10 minutes for instances to initialize"
echo "   2. Run ./connect-to-cluster.sh for connection instructions"
echo "   3. Setup your GitHub repository with the k8s manifests"
echo "   4. Configure ArgoCD to sync with your repository"