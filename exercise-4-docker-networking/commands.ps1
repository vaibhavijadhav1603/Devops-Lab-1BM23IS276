# Exercise 4 - Docker Networking with multiple containers
# Run in PowerShell from this folder with Docker Desktop running.
# This uses Docker Desktop's docker (not minikube's docker-env).

# Task 1 - create a bridge network
docker network create --driver bridge my-bridge-net

# Task 2 - verify the network
docker network ls

# Task 3 - inspect the network
docker network inspect my-bridge-net

# Task 4 - build the flask image and launch the containers
docker build -t flask-api .
docker run -d --name mysql --net=my-bridge-net -e MYSQL_ROOT_PASSWORD=rootpass mysql:latest
docker run -d --name redis --net=my-bridge-net redis:latest
docker run -d --name flask --net=my-bridge-net -p 5001:5001 flask-api
docker ps --filter network=my-bridge-net
docker logs flask
curl.exe -s http://localhost:5001/about

# Task 5 - test connectivity from the flask container
docker exec flask ping -c 3 mysql
docker exec flask ping -c 3 redis
docker network inspect my-bridge-net --format "{{range .Containers}}{{.Name}} {{.IPv4Address}}{{println}}{{end}}"

# Task 6 - clean up
docker stop mysql redis flask
docker rm mysql redis flask
docker network rm my-bridge-net
docker network ls
