#!/bin/bash
set -eo pipefail

# Validate environment
if [ "$ENVIRONMENT" != "prod" ]; then
  echo "Deployment restricted to production environment"
  exit 1
fi

# Apply infrastructure
terraform apply -auto-approve -var-file=prod.tfvars

# Update kubeconfig
aws eks update-kubeconfig --name agentic-rag-cluster --role-arn $DEPLOY_ROLE_ARN

# Deploy with Istio
istioctl install -y --set profile=default \
  --set values.global.mtls.enabled=true \
  --set values.global.sds.enabled=true

# Apply base configuration
kubectl apply -f infra/kubernetes/base/network-policies.yaml
kubectl apply -k infra/kubernetes/overlays/production

# Rotate secrets
vault kv put secret/agentic-rag/database @prod-db-creds.json

# Validate deployment
kubectl rollout status deployment/retriever-agent --timeout=300s
kubectl exec -it deploy/retriever-agent -- curl --cacert /etc/ssl/certs/ca.pem https://localhost:8000/health