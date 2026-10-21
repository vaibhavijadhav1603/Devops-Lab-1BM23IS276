# Exercise 10 - Multi-Node Minikube Cluster with Multiple Apps
# run in PowerShell from this folder

# Step 0 - clean up the old minikube cluster
minikube stop
minikube delete

# Step 1a - 3 node cluster
minikube start --nodes 3 -p devops-multinode --force
kubectl get nodes -o wide

# Step 1b - registry addon
minikube -p devops-multinode addons enable registry

# Step 2 and 3 - product_catalog.py and shopping_cart.py

# Step 4 - build the images (Dockerfile.product, Dockerfile.shopping)
docker build -t product-catalog:latest -f Dockerfile.product .
docker build -t shopping-cart:latest -f Dockerfile.shopping .
docker images --filter reference=product-catalog --filter reference=shopping-cart

# Step 5 - load the images into minikube
minikube -p devops-multinode image load product-catalog:latest
minikube -p devops-multinode image load shopping-cart:latest
minikube -p devops-multinode ssh -- docker images
minikube -p devops-multinode ssh -n devops-multinode-m02 -- docker images
minikube -p devops-multinode ssh -n devops-multinode-m03 -- docker images

# Step 6 - deployments
kubectl apply -f product_catalog_deployment.yaml
kubectl apply -f shopping_cart_deployment.yaml   # failed first: namespace devops-exercise not found, changed it to default

# Step 7 - services
kubectl apply -f product_catalog_service.yaml
kubectl apply -f shopping_cart_service.yaml

# Step 8 - check which node each pod is on
kubectl get pods -o wide
kubectl get deployments
kubectl get services

# Step 9 - open each one in a new terminal and keep it open (ports change every time)
minikube -p devops-multinode service product-catalog-service
minikube -p devops-multinode service shopping-cart-service

# Step 10 - test with curl (curl.exe, not the PowerShell curl alias)
curl.exe http://127.0.0.1:55118/products
curl.exe http://127.0.0.1:55119/cart
curl.exe -X POST http://127.0.0.1:55119/cart -H "Content-Type: application/json" -d '{\"id\": 1, \"name\": \"Laptop\", \"quantity\": 1}'
curl.exe http://127.0.0.1:55119/cart

# extra - GET the cart a few times and check the cart inside each pod
1..8 | ForEach-Object { "$_ : " + (curl.exe -s http://127.0.0.1:55119/cart) }
foreach ($p in (kubectl get pods -l app=shopping-cart -o name)) { kubectl exec $p -- python -c "import urllib.request;print(urllib.request.urlopen('http://127.0.0.1/cart').read().decode())" }

# cleanup (Ctrl+C in both service terminals first)
kubectl delete -f product_catalog_service.yaml -f shopping_cart_service.yaml -f product_catalog_deployment.yaml -f shopping_cart_deployment.yaml
kubectl get pods
