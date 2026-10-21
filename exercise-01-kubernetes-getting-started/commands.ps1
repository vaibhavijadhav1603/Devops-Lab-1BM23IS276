# Exercise 1 - Kubernetes Getting Started (Hello Pod)
# Run in PowerShell with Docker Desktop running.

# 1. Start the Minikube cluster
minikube start --driver=docker

# Method A - imperative (kubectl commands)
kubectl run hello-k8s --image=nginx --port=80
kubectl get pods
kubectl expose pod hello-k8s --type=NodePort --port=80
kubectl get svc hello-k8s
minikube service hello-k8s          # keep this terminal open

# Cleanup of Method A
kubectl delete service hello-k8s
kubectl delete pod hello-k8s

# Method B - declarative (YAML files)
kubectl apply -f hello-k8s-pod.yaml
kubectl wait --for=condition=Ready pod/hello-k8s --timeout=180s
kubectl apply -f hello-k8s-service.yaml
kubectl get pods,svc -l run=hello-k8s
minikube service hello-k8s          # keep this terminal open

# Cleanup of Method B
kubectl delete -f hello-k8s-service.yaml
kubectl delete -f hello-k8s-pod.yaml
