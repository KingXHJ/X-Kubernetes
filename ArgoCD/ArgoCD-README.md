# Setup ArgoCD 
Argo CD is a declarative continuous delivery tool for Kubernetes applications. It uses the GitOps style to create and manage Kubernetes clusters. When any changes are made to the application configuration in Git, Argo CD will compare it with the configurations of the running application and notify users to bring the desired and live state into sync.

Argo CD has been developed under the Cloud Native Computing Foundation’s (CNCF) Argo Project- a project, especially for Kubernetes application lifecycle management. The project also includes Argo Workflow, Argo Rollouts, and Argo Events.. Each solves a particular set of problems in the agile development process and make the Kubernetes application delivery scalable and secure.

## Install ArgoCD
1. 提前准备好
    1. 01-argocd-cm.yaml
    1. 02-argocd-rbac-cm.yaml
    两个文件


1. [Install ArgoCD](./script/01-argocd-install.sh)


1. Check Resource
    ```sh
    
    kubectl get all -n argocd
    ```


1. Login, then chang user name and password using the [script](./script/02-argocd-account.sh)


1. Access The Argo CD API Server

    ```sh

    # Maually Port Forward
    kubectl edit -n argocd svc argocd-server

    # Port Forward(No Return)
    kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 &

    # Change Service to NodePort
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}' 

    # Check Ports
    kubectl get svc -n argocd

    ```


1. ArgoCD Change To UI Mode
    ```sh

    az network nsg rule create -g rg-cka -n argocd-http-inbound --access allow --destination-address-prefixes '*' --destination-port-range <NodePort> --direction inbound --nsg-name cka-nsg --protocol '*' --source-address-prefixes '*' --source-port-range '*' --priority 1002
    az network nsg rule create -g rg-cka -n argocd-https-inbound --access allow --destination-address-prefixes '*' --destination-port-range <NodePort> --direction inbound --nsg-name cka-nsg --protocol '*' --source-address-prefixes '*' --source-port-range '*' --priority 1003
    ```


1. Clean Up
    ```sh

    kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl delete namespace argocd
    ```
