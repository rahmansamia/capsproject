#!/bin/bash

echo "🔧 Kubernetes Cluster Setup Helper"

# Get Terraform outputs
cd terraform
BASTION_IP=$(terraform output -raw bastion_public_ip)
MASTER_IP=$(terraform output -raw k8s_master_private_ip)
WORKER_IPS=($(terraform output -json k8s_worker_private_ips | jq -r '.[]'))

echo "📋 Cluster Information:"
echo "   Bastion Host: $BASTION_IP"
echo "   Master Node: $MASTER_IP"
echo "   Worker Nodes: ${WORKER_IPS[@]}"

cd ..

cat > cluster-setup-commands.sh << EOF
#!/bin/bash

echo "Run these commands to complete cluster setup:"
echo ""
echo "1. SSH to bastion host:"
echo "   ssh -i your-key.pem ubuntu@$BASTION_IP"
echo ""
echo "2. From bastion, SSH to master node:"
echo "   ssh ubuntu@$MASTER_IP"
echo ""
echo "3. Get the join command:"
echo "   cat /home/ubuntu/join-command.sh"
echo ""
echo "4. SSH to each worker node and run the join command:"
for ip in ${WORKER_IPS[@]}; do
    echo "   ssh ubuntu@$ip"
    echo "   sudo \$(cat /home/ubuntu/join-command.sh)  # Copy from master"
done
echo ""
echo "5. Verify cluster:"
echo "   kubectl get nodes"
echo ""
echo "6. Deploy applications:"
echo "   kubectl apply -f /home/ubuntu/k8s/"
echo ""
echo "7. Check ArgoCD:"
echo "   kubectl get pods -n argocd"
echo "   kubectl port-forward svc/argocd-server-nodeport -n argocd 8080:80 --address 0.0.0.0"
EOF

chmod +x cluster-setup-commands.sh

echo "✅ Setup commands generated in cluster-setup-commands.sh"
echo "📖 Run ./cluster-setup-commands.sh for detailed instructions"