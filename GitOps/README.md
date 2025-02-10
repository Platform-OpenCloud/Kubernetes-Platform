# Kubernetes 

## 1. calico


## 2. metrics-server

- 생성
```bash
kubectl create -f https://raw.githubusercontent.com/Cloud-Web-Platform/Atlas-PlayGround/refs/heads/develop/GitOps/k8s-1.32/metrics-server-0.7.2/components.yaml
```

- 변경
```Bash
kubectl apply -f https://raw.githubusercontent.com/Cloud-Web-Platform/Atlas-PlayGround/refs/heads/develop/GitOps/k8s-1.32/metrics-server-0.7.2/components.yaml
```

# ArgoCD

## 3. ArgoCD Image Updater

- Docker Hub Secret 등록
```Bash
kubectl create secret docker-registry docker-credentials \
  --docker-server=https://registry-1.docker.io \
  --docker-username=username \
  --docker-password=password \
  -n argocd
```

## Longhorn

- Containerd Config 변경
- /etc/containerd/config.toml
```bash
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
  MountPropagation = "rshared"
```
