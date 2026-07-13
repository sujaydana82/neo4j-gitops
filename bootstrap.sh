#!/bin/bash

echo "=========================================="
echo "🚀 Neo4j GitOps POC Bootstrap Starting..."
echo "=========================================="

# --- 1. Start Minikube ---
echo "📦 Starting Minikube..."
minikube start --cpus=4 --memory=8192

# --- 2. Create ArgoCD Namespace ---
echo "📁 Creating ArgoCD namespace..."
kubectl create namespace argocd 2>/dev/null

# --- 3. Install ArgoCD ---
echo "📥 Installing ArgoCD..."
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# --- 4. Wait for ArgoCD pods ---
echo "⏳ Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=180s

# --- 5. Port-forward ArgoCD UI ---
echo "🌐 Starting ArgoCD port-forward (localhost:8080)..."
echo "👉 Keep this terminal open or run in another terminal:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443 &"
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

sleep 5

# --- 6. Create Neo4j namespace ---
echo "📁 Creating Neo4j namespace..."
kubectl create namespace neo4j 2>/dev/null

# --- 7. Apply ArgoCD Application (GitOps) ---
echo "📥 Applying ArgoCD Neo4j GitOps Application..."
echo "⚠️ Make sure you updated repoURL in argocd/neo4j-app.yaml"
kubectl apply -f argocd/neo4j-app.yaml

# --- 8. Wait for Neo4j cluster pods ---
echo "⏳ Waiting for Neo4j cluster pods..."
kubectl wait --for=condition=Ready pods --all -n neo4j --timeout=300s

# --- 9. Show cluster status ---
echo "📊 Neo4j cluster pods:"
kubectl get pods -n neo4j

echo "=========================================="
echo "🎉 Bootstrap Complete!"
echo "Open ArgoCD UI: https://localhost:8080"
echo "Login with username: admin"
echo "Password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo ""
echo "Run tests:"
echo "bash tests/cluster-tests.sh"
echo "=========================================="


