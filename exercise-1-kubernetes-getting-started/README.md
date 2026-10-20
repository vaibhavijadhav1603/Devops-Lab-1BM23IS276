# Exercise 1 - Kubernetes Getting Started (Hello Pod)

## Aim
To start a local Kubernetes cluster using Minikube, deploy the `nginx` image as a Pod
(simulating Zepto's storefront web app), expose it as a NodePort Service and access it
from the browser.

## Files
| File | Description |
|------|-------------|
| `README.md` | Lab record (this file) |

No YAML files are needed for this exercise. The Pod and Service are created directly with `kubectl` commands.

## Environment
- OS: Windows 11 (PowerShell)
- Docker Desktop 29.8.2
- minikube v1.38.1 (Docker driver)
- kubectl client v1.36.4

## Procedure

1. Start a local Kubernetes cluster with Minikube (Docker driver):
   ```powershell
   minikube start --driver=docker
   ```
2. Create the first Pod using the Nginx image:
   ```powershell
   kubectl run hello-k8s --image=nginx --port=80
   ```
3. Verify the Pod is running:
   ```powershell
   kubectl get pods
   ```
4. Expose the Pod as a NodePort Service:
   ```powershell
   kubectl expose pod hello-k8s --type=NodePort --port=80
   kubectl get svc hello-k8s
   ```
5. Open the app in the browser:
   ```powershell
   minikube service hello-k8s
   ```
   On Windows with the Docker driver, minikube opens a tunnel to `127.0.0.1` and the
   terminal has to stay open while the page is being viewed.
6. Check the page from the terminal and view the Pod details:
   ```powershell
   curl.exe -s http://127.0.0.1:54552
   kubectl get pods -o wide
   kubectl describe pod hello-k8s
   ```

## Output

### Step 1 - `minikube start --driver=docker`
(The kicbase image download progress bar lines are left out.)
```
😄  minikube v1.38.1 on Microsoft Windows 11 Home Single Language 25H2
🎉  minikube 1.39.0 is available! Download it: https://github.com/kubernetes/minikube/releases/tag/v1.39.0
💡  To disable this notice, run: 'minikube config set WantUpdateNotification false'

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

### Step 2 - `kubectl run hello-k8s --image=nginx --port=80`
```
pod/hello-k8s created
```

### Step 3 - `kubectl get pods`
```
NAME        READY   STATUS    RESTARTS   AGE
hello-k8s   1/1     Running   0          16s
```

### Step 4 - `kubectl expose pod hello-k8s --type=NodePort --port=80`
```
service/hello-k8s exposed
NAME        TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
hello-k8s   NodePort   10.100.16.26   <none>        80:31976/TCP   0s
```

### Step 5 - `minikube service hello-k8s`
```
┌───────────┬───────────┬─────────────┬───────────────────────────┐
│ NAMESPACE │   NAME    │ TARGET PORT │            URL            │
├───────────┼───────────┼─────────────┼───────────────────────────┤
│ default   │ hello-k8s │ 80          │ http://192.168.49.2:31976 │
└───────────┴───────────┴─────────────┴───────────────────────────┘
🔗  Starting tunnel for service hello-k8s.
┌───────────┬───────────┬─────────────┬────────────────────────┐
│ NAMESPACE │   NAME    │ TARGET PORT │          URL           │
├───────────┼───────────┼─────────────┼────────────────────────┤
│ default   │ hello-k8s │             │ http://127.0.0.1:54552 │
└───────────┴───────────┴─────────────┴────────────────────────┘
🎉  Opening service default/hello-k8s in default browser...
```

### Step 6 - Page fetched from the terminal (`curl.exe -s http://127.0.0.1:54552`, first lines)
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy, 
API gateway, load balancer, content cache, or other features.</p>
```

`kubectl get pods -o wide`
```
NAME        READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
hello-k8s   1/1     Running   0          36s   10.244.0.3   minikube   <none>           <none>
```

`kubectl describe pod hello-k8s` (first lines)
```
Name:             hello-k8s
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Tue, 20 Oct 2026 22:16:16 +0530
Labels:           run=hello-k8s
Annotations:      <none>
Status:           Running
IP:               10.244.0.3
IPs:
  IP:  10.244.0.3
Containers:
  hello-k8s:
    Container ID:   docker://b9fb5a0325d3985c4914eeb1b8f49ba8ba546b18795de6875e56c2679af7dea8
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:bc4cad49969aaf95eb4eecec5572846f86e59f1e8332aba36ed64b91aff8b724
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Tue, 20 Oct 2026 22:16:31 +0530
    Ready:          True
    Restart Count:  0
```

## Observations
- `minikube start` created a single node cluster (`minikube`) running inside a Docker container.
- `kubectl run` created a single Pod `hello-k8s` with the label `run=hello-k8s`. The Pod was
  scheduled on node `minikube` and given the Pod IP `10.244.0.3`.
- `kubectl expose` created a NodePort Service that uses the label `run=hello-k8s` as its selector.
  Port 80 of the Pod was mapped to NodePort `31976` on the node IP `192.168.49.2`.
- With the Docker driver on Windows the node IP is not reachable from the host directly, so
  `minikube service` opened a tunnel on `http://127.0.0.1:54552` and opened it in the browser.
- The Nginx welcome page was shown, so the container is running and reachable through the Service.

## Result
The Nginx image was deployed as a Pod on a local Minikube Kubernetes cluster, exposed using a
NodePort Service, and the Nginx welcome page was accessed successfully from the browser.

## Cleanup
```powershell
kubectl delete service hello-k8s
kubectl delete pod hello-k8s
```
