# X-Kubernetes
My k8s study

> Thanks for [wrijugh](https://github.com/wrijugh) provide [the ways of kubeadm](https://github.com/wrijugh/cka-setup-guide) to start a k8s on Azure. And I turn it to suit mine.


## 目录
- [K8s结构](#)
- [安装K8s](#安装k8s)
- [Helm](#helm)
- [Prometheus](#prometheus)
- [Cert Manager & Let's Ingress](#cert-manager--lets-ingress)
- [mkcert](#mkcert)
- [ArgoCD](#argocd)
- [Ingress Nginx](#ingress-nginx)
- [Study Notes](#study-notes)


## K8s结构
![K8s结构](./Structure/k8s-base-structure.png)


## 安装K8s
- [Install cka on Azure(successful)](./CKASetupGuide/CKA-Setup-README.md)
- [Install Docker and K8S on Ubuntu2004](./InstallFailed/InstallDocker&K8SOnUbuntu2004.md)
- [Install K8S on Azure](./InstallFailed/InstallK8sOnAzure.md)

1. 20230806
   - 通过对 ```/etc/kubernetes/manifests/kube-apiserver.yaml``` 的 ```spec.containers.command``` 中添加 ```- --service-node-port-range=1-65535``` 配置，要注意格式的修改，实现了 NodePort 在 ```[1, 65535]``` 范围的更改


## Helm
- [Install Helm](./Helm/Helm-README.md)


## Prometheus
- [Install Prometheus](./Prometheus/Promethus-README.md)


## Cert Manager & Let's Ingress
- [Cert Manager & Let's Encrypt](./CertManager&LetsEncrypt/CertManager&LetsEncrypt-README.md)


## mkcert



## ArgoCD
- [Install ArgoCD](./ArgoCD/ArgoCD-README.md)

1. 20230806
   - 目前实现了通过域名（443端口哦！）的根路径（没有实现 ingress 自定义路径）对 ArgoCD 进行 Cert Manager + Let's Encrypt 的访问。TLS是直接从 Ingress 的前端 PassThrough 到了 ArgoCD（没有实现在 ingress 端脱壳）
      - 来自claude的解答：Argo CD的服务需要占用整个域名。因为Argo CD会处理所有路径的请求
   - ArgoCD 的 Ingress 文档有 Bug，现在自定义 TLS 访问要用 ```argocd-server-tls``` 做 SecretName


## Ingress Nginx
- [Install Ingress Nginx](./Ingress-Nginx/Ingress-Nginx-README.md)


## Study Notes
- [Kubernetes 权威指南](./Notes/KubernetesAuthoritativeGuideBookNotes/Q&A.md)
- [深入剖析Kubernetes](./Notes/DeepAnalysisKubernetesNotes/00%20Preview%20Section.md)
