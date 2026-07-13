# Neo4j Kubernetes GitOps POC (Minikube + ArgoCD + Helm)

This repository contains a complete setup for testing Neo4j causal clustering on Kubernetes using:

- Minikube
- ArgoCD GitOps
- Helm chart
- Automated cluster test scripts

## Prerequisites

- Minikube
- kubectl
- helm
- argocd CLI (optional)
- GitHub repo

## Steps

### 1. Start Minikube
minikube start --cpus=4 --memory=8192

### 2. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

### 3. Apply ArgoCD Application
kubectl apply -f argocd/neo4j-app.yaml

### 4. Wait for Neo4j cluster
kubectl get pods -n neo4j

### 5. Run cluster tests
bash tests/cluster-tests.sh

