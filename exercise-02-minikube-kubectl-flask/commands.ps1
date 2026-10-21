# Exercise 2 - Deploy a Flask app on Minikube using kubectl and yaml
# Run in PowerShell from this folder with Docker Desktop running.

# Step 1 - start minikube
minikube start --driver=docker

# Step 4 - use minikube's docker daemon and build the image
minikube -p minikube docker-env --shell powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker build -t flask-app:latest .
docker images flask-app

# Step 6 to 12 - deploy and check (flask-deployment.yaml with only the Deployment part)
kubectl apply -f flask-deployment.yaml
kubectl get deployments
kubectl get pods -l app=flask-app
kubectl describe deployment flask-app
kubectl logs <pod-name>
kubectl get services
curl.exe http://127.0.0.1:15000      # fails, port is not exposed

# Step 13 - after adding the Service part to flask-deployment.yaml
kubectl apply -f flask-deployment.yaml
kubectl get services
minikube service flask-app-service --url    # keep this terminal open
curl.exe http://127.0.0.1:<port>            # run in a new terminal

# Cleanup
kubectl delete -f flask-deployment.yaml
kubectl get pods
