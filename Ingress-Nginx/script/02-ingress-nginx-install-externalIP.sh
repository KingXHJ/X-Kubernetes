# 1 Get the resource group name of the cluster 
# az aks show --resource-group staging --name my-demo-cluster--query nodeResourceGroup -o tsv


# 2 Replace Resource Group value
# az network public-ip create --resource-group rg-cka --name ingress-nginx-argocd --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv


# 3 Create a namespace for your ingress resources
kubectl create namespace ingress-nginx
# Add the official stable repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add stable https://charts.helm.sh/stable   
helm repo update
helm search repo ingress-nginx --versions

# Customizing the Chart Before Installing. 
helm show values ingress-nginx/ingress-nginx


# 4 Install the Ingress-Nginx
# URL: https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.replicaCount=1 \
    --set controller.nodeSelector."kubernetes.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP="52.168.134.135" 


# 5 Set Node Port Mode
kubectl patch svc ingress-nginx -n ingress-nginx -p '{"spec": {"type": "NodePort"}}'


# Clean Up
# kubectl delete -n ingress-nginx -f ./kubernetes/ingress/controller/nginx/manifests/nginx-ingress.${APP_VERSION}.yaml
# kubectl delete namespace ingress-nginx


