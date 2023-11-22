# Setup Cert Manager & Let's Encrypt

## 目录
- [Install Cert Manager & Let's Encrypt](#install-cert-manager--lets-encrypt)
- [Config TLS for ArgoCD](#config-tls-for-argocd)


## Install Cert Manager & Let's Encrypt
- [Install Cert Manager & Let's Encrypt](./script/01-lets-encrypt-cert-manager.sh)


## Config TLS for ArgoCD 
1. When ArgoCD has been [setup](../ArgoCD/ArgoCD-README.md), set issuer for ArgoCD
    ```sh
    
    kubectl apply -f 01-argocd-lets-encrypt-cert-manager-clusterissuer.yaml
    ```
1. When Nginx Ingress has been [setup](../Ingress/Ingress-README.md), set an ingress for ArgoCD
    ```sh

    kubectl apply -f 03-argocd-ingress-nginx-passthrough.yaml
    kubectl apply -f 03-argocd-ingress-nginx-termination-at-ingress-controller.yaml
    kubectl apply -f 03-argocd-ingress-nginx-le-termination-at-ingress-controller.yaml
    ```

- 注意：
    1. 如果绑定域名绑定的是 tailscale 的 IP，是没办法使用 Let's Encrypt 的，因为那是内网 IP
    1. 如果使用 CloudFlare Zero Trust 或者 frp 内网穿透至一个有公网 IP 的云服务器上，只要使用的是 80 端口，那么 HTTP-01 Challenge 就能成功，但是不保证能通过域名访问罢了。采用此方法的 ingress.yaml 为 ```kubectl apply -f 03-argocd-ingress-nginx-le-termination-at-ingress-controller.yaml```
