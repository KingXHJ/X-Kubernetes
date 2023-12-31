# Setup mkcert

## 目录
- [Install mkcert](#install-mkcert)
- [Start to Creat a CA and Certificates](#start-to-creat-a-ca-and-certificates)
- [提取CA的ca.crt](#提取ca的cacrt)
- [Create Secret for ingress-nginx](#create-secret-for-ingress-nginx)
- [Delete Secret](#delete-secret)
- [Delete CA](#delete-ca)


## Install mkcert
- [Install mkcert](./script/01-mkcert-install.sh)


## Start to Creat a CA and Certificates

**"*.example.com"只能代表三级域名，四级及往后的域名无法代理**

```bash

$ mkcert -install
Created a new local CA 💥
The local CA is now installed in the system trust store! ⚡️
The local CA is now installed in the Firefox trust store (requires browser restart)! 🦊

# $ mkcert example.com "*.example.com" example.test localhost 127.0.0.1 ::1
$ mkcert argocd.xingress.kingxhj.eu.org "*.argocd.xingress.kingxhj.eu.org"

Created a new certificate valid for the following names 📜
 - "example.com"
 - "*.example.com"
 - "example.test"
 - "localhost"
 - "127.0.0.1"
 - "::1"

The certificate is at "./example.com+5.pem" and the key at "./example.com+5-key.pem" ✅
```

将私钥和公钥进行重命名：

```bash
# $ mv ./example.com+5.pem ./cert.pem
# $ mv ./example.com+5-key.pem ./key.pem

$ mv ./argocd.xingress.kingxhj.eu.org+1.pem ./cert.pem
$ mv ./argocd.xingress.kingxhj.eu.org+1-key.pem ./key.pem
```


## 提取CA的ca.crt

```bash

$ SECRET_PATH=$(pwd)
$ CA_PATH=$(mkcert -CAROOT /root/.local/share/mkcert)
$ cd $CA_PATH
$ cp ./rootCA.pem $SECRET_PATH/ca.crt
$ cd $SECRET_PATH
```



## Create Secret for ingress-nginx

**注意：ingress 规则的 namespace，必须和 secretname 的 namespace 保持一致。至少在部署 argocd 上是这样的**

```bash

$ kubectl create -n argocd secret tls argocd-repo-server-tls --cert=/path/to/cert.pem --key=/path/to/key.pem

or

$ kubectl create -n argocd secret tls argocd-xingress-http --cert=/path/to/cert.pem --key=/path/to/key.pem
$ kubectl create -n argocd secret tls argocd-xingress-grpc --cert=/path/to/cert.pem --key=/path/to/key.pem
```

举例：
```bash

$ kubectl create -n argocd secret tls argocd-xingress-http  --cert=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/argocd.xingress.kingxhj.eu.org+1.pem --key=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/argocd.xingress.kingxhj.eu.org+1-key.pem

$ kubectl create -n argocd secret tls argocd-xingress-grpc  --cert=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/argocd.xingress.kingxhj.eu.org+1.pem --key=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/argocd.xingress.kingxhj.eu.org+1-key.pem
```

or

```bash

$ kubectl create -n argocd secret generic argocd-xingress-http  --from-file=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/cert.pem --from-file=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/key.pem --from-file=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/ca.crt

$ kubectl create -n argocd secret generic argocd-xingress-grpc  --from-file=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/cert.pem --from-file=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/key.pem --from-file=/home/ubuntu/Kubernetes/Ingress-Nginx/ArgoCD-Ingress-Nginx-Secret/ca.crt
```


## Delete Secret

```bash

$ kubectl delete -n argocd secret argocd-xingress-http
$ kubectl delete -n argocd secret argocd-xingress-grpc
```


## Delete CA
```bash

$ mkcert -uninstall
  Uninstall the local CA (but do not delete it).
$ CA_PATH=$(mkcert -CAROOT /root/.local/share/mkcert)
$ rm -rf $CA_PATH
```
