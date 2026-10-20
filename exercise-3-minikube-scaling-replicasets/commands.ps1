# Exercise 3 - Scaling Flask App on Single Node using ReplicaSets
# Run in PowerShell from this folder with Docker Desktop running.

# Step 1 - clean up previous minikube
minikube stop
minikube delete

# Step 2 - start minikube with a single node
minikube start --nodes=1 --driver=docker
kubectl get nodes

# Build the image inside minikube's docker (done before applying the yaml)
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker build -t flashsale:1.0 .
docker images flashsale

# Step 4 - apply the ReplicaSet and Service
kubectl apply -f flashsale-replicaset.yaml

# Step 6 - verify pods and replicaset
kubectl get pods
kubectl get rs
kubectl get svc flashsale-svc

# Step 7 to 9 - scale to 5 replicas and verify
kubectl scale rs flashsale-rs --replicas=5
kubectl get rs
kubectl get pods

# Step 10 and 11 - delete one pod and verify it is recreated
kubectl delete pod <pod-name>
kubectl get pods
kubectl get pods -o wide

# Extra - send requests to the service from a temporary pod to see which pod serves them
kubectl run curl-test --image=curlimages/curl:8.10.1 --rm -i --restart=Never -- sh -c 'curl -s http://flashsale-svc/; echo; for i in 1 2 3 4 5 6 7 8 9 10; do curl -s "http://flashsale-svc/buy?user=$i"; echo; done'

# Extra - describe the replicaset
kubectl describe rs flashsale-rs

# Cleanup
kubectl delete -f flashsale-replicaset.yaml
kubectl get rs,pods,svc
