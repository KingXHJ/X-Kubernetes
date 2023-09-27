# 1 Get the installation YAML
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm search repo ingress-nginx --versions

CHART_VERSION="4.7.1"
APP_VERSION="1.8.1"

mkdir -p ./kubernetes/ingress/controller/nginx/manifests/

helm template ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--version ${CHART_VERSION} \
--namespace ingress-nginx \
> ./kubernetes/ingress/controller/nginx/manifests/nginx-ingress.${APP_VERSION}.yaml


# 2 Deploy the Ingress controller
kubectl create namespace ingress-nginx
kubectl apply -f ./kubernetes/ingress/controller/nginx/manifests/nginx-ingress.${APP_VERSION}.yaml


# 3 Check the installation
kubectl -n ingress-nginx get pods


# 4 Set Node Port Mode
kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "NodePort"}}'
kubectl patch svc ingress-nginx-controller -n ingress-nginx --type merge --patch-file 02-ingress-nginx-nodeport.yaml


# 6 Install Krew

# 6.1 Make sure that git is installed

# 6.2 Run this command to download and install krew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# 6.3 Add the $HOME/.krew/bin directory to your PATH environment variable. To do this, update your .bashrc or .zshrc file and append the following line
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# and restart your shell.
source ~/.bashrc

# 6.4 Check the installation
kubectl krew version


# 7 Install ingress-nginx kubectl plugin
kubectl krew install ingress-nginx
kubectl ingress-nginx --help

# 检查 nginx.conf 配置
kubectl ingress-nginx lint

# 检查后端（类似于kubectl describe ingress）
kubectl ingress-nginx backends

# 查看日志
kubectl ingress-nginx logs


# 9 Azure Security Group
# az network nsg rule create -g rg-cka -n argocd-http-inbound --access allow --destination-address-prefixes '*' --destination-port-range 80 --direction inbound --nsg-name cka-nsg --protocol '*' --source-address-prefixes '*' --source-port-range '*' --priority 1002
# az network nsg rule create -g rg-cka -n argocd-http-outbound --access allow --destination-address-prefixes '*' --destination-port-range '*' --direction outbound --nsg-name cka-nsg --protocol '*' --source-address-prefixes '*' --source-port-range 80 --priority 1002
# az network nsg rule create -g rg-cka -n argocd-https-inbound --access allow --destination-address-prefixes '*' --destination-port-range 443 --direction inbound --nsg-name cka-nsg --protocol '*' --source-address-prefixes '*' --source-port-range '*' --priority 1003
# az network nsg rule create -g rg-cka -n argocd-https-outbound --access allow --destination-address-prefixes '*' --destination-port-range '*' --direction outbound --nsg-name cka-nsg --protocol '*' --source-address-prefixes '*' --source-port-range 443 --priority 1003


# Clean Up
# kubectl delete -n ingress-nginx -f ./kubernetes/ingress/controller/nginx/manifests/nginx-ingress.${APP_VERSION}.yaml
# kubectl delete namespace ingress-nginxs