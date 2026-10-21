# Exercise 3 - Scaling Flask App on Single Node using ReplicaSets

## Aim
To run a flash sale Flask app as 3 pods using a ReplicaSet on a single node minikube cluster,
scale it to 5 pods, delete one pod and see the ReplicaSet create a new one automatically.

## Files
- `app.py` - flash sale Flask app with `/`, `/buy` and `/health` routes. Shows which pod served the request.
- `Dockerfile` - builds the `flashsale:1.0` image (python:3.11-slim + flask + gunicorn on port 5000)
- `flashsale-replicaset.yaml` - ReplicaSet `flashsale-rs` (3 replicas, readiness and liveness probes,
  cpu/memory limits) and ClusterIP Service `flashsale-svc` (port 80 -> 5000)
- `commands.ps1` - all the commands I used

Notes (name mismatches in the exercise file):
- The Dockerfile in the exercise copies `ex3-flash-sale.py` but gunicorn runs `app:app`, so the file
  must be `app.py`. I named the file `app.py` and used `COPY app.py .`.
- The exercise builds the image as `<dockerhub-username>/flashsale:1.0` and later as `flask-app`, but the
  YAML uses `flashsale:1.0`. I built it as `flashsale:1.0` in minikube's docker so it matches the YAML.
  So I did not push it to Docker Hub.
- Steps 7 to 11 in the exercise use `flask-app-rs` but the ReplicaSet in the YAML is `flashsale-rs`.
  I used `flashsale-rs`.
- In the exercise the YAML is applied (Step 4) before building the image (Step 5). I built the image
  first so the pods could start straight away.
- On Windows PowerShell I used `& minikube -p minikube docker-env --shell powershell | Invoke-Expression`
  instead of `eval $(minikube docker-env)`.

## Software used
- Windows 11 (PowerShell)
- Docker Desktop 29.8.2
- minikube v1.38.1 (docker driver)
- kubectl v1.36.4

## Procedure
1. Stop and delete the old minikube cluster
   ```powershell
   minikube stop
   minikube delete
   ```
2. Start minikube with a single node and check nodes
   ```powershell
   minikube start --nodes=1 --driver=docker
   kubectl get nodes
   ```
3. Create `app.py`, `Dockerfile` and `flashsale-replicaset.yaml`
4. Build the image using minikube's docker
   ```powershell
   & minikube -p minikube docker-env --shell powershell | Invoke-Expression
   docker build -t flashsale:1.0 .
   docker images flashsale
   ```
5. Apply the ReplicaSet and Service
   ```powershell
   kubectl apply -f flashsale-replicaset.yaml
   ```
6. Verify the pods and replicaset
   ```powershell
   kubectl get pods
   kubectl get rs
   kubectl get svc flashsale-svc
   ```
7. Scale the ReplicaSet to 5 replicas
   ```powershell
   kubectl scale rs flashsale-rs --replicas=5
   ```
8. Verify the replicaset
   ```powershell
   kubectl get rs
   ```
9. Verify the pods
   ```powershell
   kubectl get pods
   ```
10. Delete one pod
    ```powershell
    kubectl delete pod flashsale-rs-dd5s2
    ```
11. Verify the pods again and see on which node they are running
    ```powershell
    kubectl get pods
    kubectl get pods -o wide
    kubectl get rs
    ```
12. Extra: send requests to the service from a temporary curl pod to see which pod serves each request
    ```powershell
    kubectl run curl-test --image=curlimages/curl:8.10.1 --rm -i --restart=Never -- sh -c 'curl -s http://flashsale-svc/; echo; for i in 1 2 3 4 5 6 7 8 9 10; do curl -s "http://flashsale-svc/buy?user=$i"; echo; done'
    ```
13. Extra: describe the replicaset
    ```powershell
    kubectl describe rs flashsale-rs
    ```

## Output

**Step 1 - minikube stop and delete**
```
✋  Stopping node "minikube"  ...
🛑  Powering off "minikube" via SSH ...
🛑  1 node stopped.
🔥  Deleting "minikube" in docker ...
🔥  Deleting container "minikube" ...
🔥  Removing C:\Users\vaibh\.minikube\machines\minikube ...
💀  Removed all traces of the "minikube" cluster.
```

**Step 2 - minikube start --nodes=1**
```
😄  minikube v1.38.1 on Microsoft Windows 11 Home Single Language 25H2
✨  Using the docker driver based on user configuration
❗  Starting v1.39.0, minikube will default to "containerd" container runtime. See #21973 for more info.
📌  Using Docker Desktop driver with root privileges
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.50 ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

kubectl get nodes
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   7s    v1.35.1
```

**Step 4 - docker build -t flashsale:1.0 .** (layer download lines and pip download lines removed)
```
#0 building with "default" instance using docker driver
#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 213B 0.0s done
#1 DONE 0.1s
#2 [internal] load metadata for docker.io/library/python:3.11-slim
#2 DONE 3.1s
#4 [internal] load .dockerignore
#4 transferring context: 2B done
#4 DONE 0.1s
#5 [internal] load build context
#5 transferring context: 771B 0.0s done
#5 DONE 0.1s
#6 [1/4] FROM docker.io/library/python:3.11-slim@sha256:e88e9763f943ec1834f992a4b51e0f24500486803e8bc534e5767af9ea65f6ce
#6 DONE 8.3s
#7 [2/4] WORKDIR /app
#7 DONE 0.2s
#8 [3/4] COPY app.py .
#8 DONE 0.4s
#9 [4/4] RUN pip install --no-cache-dir flask gunicorn
#9 3.630 Collecting flask
#9 3.790 Collecting gunicorn
#9 4.530 Installing collected packages: markupsafe, itsdangerous, gunicorn, click, blinker, werkzeug, jinja2, flask
#9 5.548 Successfully installed blinker-1.9.0 click-8.5.0 flask-3.1.3 gunicorn-26.2.0 itsdangerous-2.2.0 jinja2-3.1.6 markupsafe-3.0.4 werkzeug-3.1.9
#9 5.548 WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
#9 5.731 
#9 5.731 [notice] A new release of pip is available: 24.0 -> 26.2.2
#9 5.731 [notice] To update, run: pip install --upgrade pip
#9 DONE 6.0s
#10 exporting to image
#10 exporting layers
#10 exporting layers 0.5s done
#10 writing image sha256:3a6743a5effb62a1d32340b8349d4cc2729af4526e4bc1e7e9b9d5d4ebba4f6d 0.0s done
#10 naming to docker.io/library/flashsale:1.0 0.0s done
#10 DONE 0.7s
```

docker images flashsale
```
IMAGE           ID             DISK USAGE   CONTENT SIZE   EXTRA
flashsale:1.0   3a6743a5effb        143MB             0B
```

**Step 5 - kubectl apply -f flashsale-replicaset.yaml**
```
replicaset.apps/flashsale-rs created
service/flashsale-svc created
```

**Step 6 - kubectl get pods / get rs / get svc**
```
NAME                 READY   STATUS    RESTARTS   AGE
flashsale-rs-j95gr   1/1     Running   0          6s
flashsale-rs-jswbv   1/1     Running   0          6s
flashsale-rs-lzq7l   1/1     Running   0          6s
```
```
NAME           DESIRED   CURRENT   READY   AGE
flashsale-rs   3         3         3       6s
```
```
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
flashsale-svc   ClusterIP   10.104.183.164   <none>        80/TCP    6s
```

**Step 7 - kubectl scale rs flashsale-rs --replicas=5**
```
replicaset.apps/flashsale-rs scaled
```

**Step 8 - kubectl get rs**
```
NAME           DESIRED   CURRENT   READY   AGE
flashsale-rs   5         5         5       26s
```

**Step 9 - kubectl get pods**
```
NAME                 READY   STATUS    RESTARTS   AGE
flashsale-rs-dd5s2   1/1     Running   0          10s
flashsale-rs-j95gr   1/1     Running   0          26s
flashsale-rs-jswbv   1/1     Running   0          26s
flashsale-rs-lzq7l   1/1     Running   0          26s
flashsale-rs-sqmhl   1/1     Running   0          10s
```

**Step 10 - kubectl delete pod flashsale-rs-dd5s2**
```
pod "flashsale-rs-dd5s2" deleted from default namespace
```

**Step 11 - kubectl get pods**
```
NAME                 READY   STATUS    RESTARTS   AGE
flashsale-rs-fjn4b   1/1     Running   0          8s
flashsale-rs-j95gr   1/1     Running   0          35s
flashsale-rs-jswbv   1/1     Running   0          35s
flashsale-rs-lzq7l   1/1     Running   0          35s
flashsale-rs-sqmhl   1/1     Running   0          19s
```

kubectl get pods -o wide
```
NAME                 READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
flashsale-rs-fjn4b   1/1     Running   0          8s    10.244.0.8   minikube   <none>           <none>
flashsale-rs-j95gr   1/1     Running   0          35s   10.244.0.5   minikube   <none>           <none>
flashsale-rs-jswbv   1/1     Running   0          35s   10.244.0.3   minikube   <none>           <none>
flashsale-rs-lzq7l   1/1     Running   0          35s   10.244.0.4   minikube   <none>           <none>
flashsale-rs-sqmhl   1/1     Running   0          19s   10.244.0.6   minikube   <none>           <none>
```

kubectl get rs
```
NAME           DESIRED   CURRENT   READY   AGE
flashsale-rs   5         5         5       36s
```

**Step 12 - requests to flashsale-svc from curl pod**
```
{"message":"Welcome to Big Sale!","pod":"flashsale-rs-jswbv","ts":1792518421.444129}

{"item":"Smartphone","served_by_pod":"flashsale-rs-fjn4b","status":"success","time":"17:47:01","user":"1"}

{"item":"Laptop","served_by_pod":"flashsale-rs-lzq7l","status":"success","time":"17:47:01","user":"2"}

{"item":"Smartphone","served_by_pod":"flashsale-rs-sqmhl","status":"success","time":"17:47:01","user":"3"}

{"item":"Laptop","served_by_pod":"flashsale-rs-sqmhl","status":"success","time":"17:47:01","user":"4"}

{"item":"Smartphone","served_by_pod":"flashsale-rs-j95gr","status":"success","time":"17:47:01","user":"5"}

{"item":"Laptop","served_by_pod":"flashsale-rs-sqmhl","status":"success","time":"17:47:01","user":"6"}

{"item":"Headphones","served_by_pod":"flashsale-rs-j95gr","status":"success","time":"17:47:01","user":"7"}

{"item":"Smartphone","served_by_pod":"flashsale-rs-jswbv","status":"success","time":"17:47:01","user":"8"}

{"item":"Shoes","served_by_pod":"flashsale-rs-j95gr","status":"success","time":"17:47:01","user":"9"}

{"item":"Shoes","served_by_pod":"flashsale-rs-sqmhl","status":"success","time":"17:47:01","user":"10"}

pod "curl-test" deleted from default namespace
```

**Step 13 - kubectl describe rs flashsale-rs**
```
Name:         flashsale-rs
Namespace:    default
Selector:     app=flashsale
Labels:       app=flashsale
Annotations:  <none>
Replicas:     5 current / 5 desired
Pods Status:  5 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=flashsale
  Containers:
   flashsale-container:
    Image:      flashsale:1.0
    Port:       5000/TCP
    Host Port:  0/TCP
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:         100m
      memory:      128Mi
    Liveness:      http-get http://:5000/health delay=10s timeout=1s period=10s #success=1 #failure=3
    Readiness:     http-get http://:5000/health delay=2s timeout=1s period=5s #success=1 #failure=3
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  65s   replicaset-controller  Created pod: flashsale-rs-lzq7l
  Normal  SuccessfulCreate  65s   replicaset-controller  Created pod: flashsale-rs-j95gr
  Normal  SuccessfulCreate  65s   replicaset-controller  Created pod: flashsale-rs-jswbv
  Normal  SuccessfulCreate  49s   replicaset-controller  Created pod: flashsale-rs-sqmhl
  Normal  SuccessfulCreate  49s   replicaset-controller  Created pod: flashsale-rs-dd5s2
  Normal  SuccessfulCreate  38s   replicaset-controller  Created pod: flashsale-rs-fjn4b
```

## Observations
- The ReplicaSet started with 3 pods and all 3 were Running.
- After scaling to 5 replicas, 2 new pods (`dd5s2` and `sqmhl`) were created.
- When I deleted the pod `flashsale-rs-dd5s2`, the ReplicaSet created a new pod `flashsale-rs-fjn4b`
  by itself, so there were still 5 pods. The events in `describe rs` also show this.
- There is only 1 node (`minikube`), so all 5 pods are running on the same node with different pod IPs.
- When requests were sent to `flashsale-svc`, different pods served them (`fjn4b`, `lzq7l`, `sqmhl`,
  `j95gr`, `jswbv`), so the service spreads the requests across the pods.
- The readiness and liveness probes use `/health` on port 5000 and all pods passed them (READY 1/1).

## Result
The flash sale Flask app was deployed using a ReplicaSet with 3 replicas, scaled to 5 replicas, and
when one pod was deleted the ReplicaSet automatically created a new pod to keep 5 replicas.

## Cleanup
```powershell
kubectl delete -f flashsale-replicaset.yaml
kubectl get rs,pods,svc
```
Output:
```
replicaset.apps "flashsale-rs" deleted from default namespace
service "flashsale-svc" deleted from default namespace
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   115s
```
