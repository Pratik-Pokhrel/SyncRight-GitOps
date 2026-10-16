# SyncRight-GitOps

Kubernetes manifests and automation for deploying **Sync-Right**, a browser-based collaborative learning platform with real-time video, chat and a shared whiteboard. ArgoCD watches this repo and keeps the cluster in sync with it.

> Work in progress. The project is built in phases and this README is updated as each one is completed.

## Overview

- **App:** Sync-Right (React, Node/Express, MongoDB, Redis, Socket.io, WebRTC). The application code lives in a separate repo. This repo holds deployment config only.
- **Cluster:** Two Ubuntu VMs (control plane and worker) built with kubeadm, containerd and Calico, on a Host-Only network.
- **Ingress and TLS:** ingress-nginx (NodePort 30080/30443) and cert-manager with a self-signed issuer.
- **GitOps:** ArgoCD pulls from this repo and reconciles the cluster to match it, including drift correction.
- **Secrets:** Sealed Secrets. Only encrypted `SealedSecret` files are committed here, so the repo can stay public.

## Repo structure

```
SyncRight-GitOps/
├─ ansible/       Cluster bootstrap automation (planned)
├─ apps/
│  └─ syncright/  App manifests and sealed secrets, watched by ArgoCD
├─ argocd/        ArgoCD Application definitions
├─ platform/      Cluster-level resources (cert issuer)
├─ scripts/       preflight-check.sh, smoke-test.sh
├─ terraform/     Platform layer as code (planned)
├─ .gitignore
├─ LICENSE
└─ README.md
```

## Roadmap

| Phase | Focus |
|---|---|
| 1 | Two-node Kubernetes cluster bring-up | 
| 2 | Deploying Sync-Right as a multi-tier app | 
| 3 | GitOps with ArgoCD and Sealed Secrets |
| 4 | Ansible and Terraform automation | 
| 5 | NetworkPolicies, adversary testing, failure testing | 
| 6 | Azure AKS and multi-cluster GitOps |


## License

See [LICENSE](LICENSE).
