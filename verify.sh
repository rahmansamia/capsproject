#!/bin/bash

echo "🔍 Verifying 3-Tier Application Deployment"

# Check Terraform outputs
cd terraform
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ Terraform state not found. Run deployment first."
    exit 1
fi

BASTION_IP=$(terraform output -raw bastion_public_ip)
MASTER_IP=$(terraform output -raw k8s_master_private_ip)
ALB_DNS=$(terraform output -raw alb_dns_name)

echo "📊 Infrastructure Status:"
echo "   ✅ Bastion Host: $BASTION_IP"
echo "   ✅ K8s Master: $MASTER_IP"
echo "   ✅ Load Balancer: $ALB_DNS"

cd ..

# Test connectivity
echo "🌐 Testing Application Connectivity:"

# Test ALB health
if curl -s --connect-timeout 10 "http://$ALB_DNS" > /dev/null; then
    echo "   ✅ Load Balancer is accessible"
else
    echo "   ⚠️  Load Balancer not yet accessible (may still be initializing)"
fi

# Test backend API
if curl -s --connect-timeout 10 "http://$ALB_DNS/api/health" > /dev/null; then
    echo "   ✅ Backend API is responding"
else
    echo "   ⚠️  Backend API not yet accessible"
fi

echo ""
echo "📋 Manual Verification Steps:"
echo "1. SSH to bastion host:"
echo "   ssh -i your-key.pem ubuntu@$BASTION_IP"
echo ""
echo "2. From bastion, connect to K8s master:"
echo "   ssh ubuntu@$MASTER_IP"
echo ""
echo "3. Check cluster status:"
echo "   kubectl get nodes"
echo "   kubectl get pods -A"
echo ""
echo "4. Check ArgoCD:"
echo "   kubectl get pods -n argocd"
echo "   kubectl port-forward svc/argocd-server-nodeport -n argocd 8080:80"
echo ""
echo "5. Access ArgoCD UI:"
echo "   http://localhost:8080"
echo "   Username: admin"
echo "   Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "6. Test application:"
echo "   Frontend: http://$ALB_DNS"
echo "   Backend API: http://$ALB_DNS/api"

echo ""
echo "🎯 Assignment Completion Checklist:"
echo "   [ ] Infrastructure deployed with Terraform"
echo "   [ ] Kubernetes cluster running on EC2"
echo "   [ ] ArgoCD installed and accessible"
echo "   [ ] Applications deployed via K8s"
echo "   [ ] Load balancer routing traffic"
echo "   [ ] Database accessible from backend"
echo "   [ ] CI/CD pipeline configured"
echo "   [ ] All components in correct subnets"