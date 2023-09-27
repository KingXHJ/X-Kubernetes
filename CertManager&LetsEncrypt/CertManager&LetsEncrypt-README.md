# Setup Cert Manager & Let's Encrypt


## Install Cert Manager & Let's Encrypt
- [Install Cert Manager & Let's Encrypt](./script/01-lets-encrypt-cert-manager.sh)

## Config TLS for ArgoCD 
1. When ArgoCD has been [setup](../ArgoCD/ArgoCD-README.md), set issuer for ArgoCD
    ```sh
    
    kubectl apply -f 01-argocd-lets-encrypt-cert-manager-clusterissuer.yaml
    ```
1. When Nginx Ingress has been [setup](../Ingress/Ingress-README.md), set an ingress for ArgoCD
    ```sh

    kubectl apply -f 03-argocd-nginx-ingress.yaml
    ```

