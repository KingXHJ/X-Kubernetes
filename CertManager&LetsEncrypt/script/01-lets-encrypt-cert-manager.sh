# URL: https://www.howtogeek.com/devops/how-to-install-kubernetes-cert-manager-and-configure-lets-encrypt/
# 1 Instell Cert Manager Uding Helm

echo "1 Instell Cert Manager Uding Helm"
# Add the Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Check Version
# https://cert-manager.io/docs/installation/helm
helm search repo cert-manager --versions
# Watch the URL and choose a option
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.crds.yaml

# Install cert-manager
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.12.0 
  # --set installCRDs=true


# 2 Adding the Kubectl Plugin
echo "2 Adding the Kubectl Plugin"
curl -L -o kubectl-cert-manager.tar.gz https://github.com/jetstack/cert-manager/releases/latest/download/kubectl-cert_manager-linux-amd64.tar.gz
tar xzf kubectl-cert-manager.tar.gz
sudo mv kubectl-cert_manager /usr/local/bin

# Now use the plugin to check your Cert-Manager installation is working:
kubectl cert-manager check api

# You should see the following output:
# The cert-manager API is ready

# Now you're ready to add an issuer to get certificates from Let's Encrypt.


# 3 Creating a Certificate Issuer
# Issuers and cluster issuers are resources which supply certificates to your cluster. 
# The basic Cert-Manager installation created so far is incapable of issuing certificates. 
# Adding an issuer that's configured to use Let's Encrypt lets you dynamically acquire new certificates for services in your cluster.

# Create a YAML file in your working directory and name it issuer.yml. Add the following content:
# lets-encrypt-issuer.yaml
# Use kubectl to add the issuer to your cluster
# kubectl apply -f 01-argocd-lets-encrypt-cert-manager-issuer.yaml


# 4 Getting a Certificate
# Now you can use your issuer to acquire a certificate for a service exposed via an Ingress resource. 
# Cert-Manager automatically monitors Ingress resources and creates certificates using the configuration in their tls field. 
# You just need to add an annotation that names the issuer or cluster issuer you want to use.
# kubectl apply -f 02-cert-argocd-secret.yaml
# ../ArgoCD/ArgoCD-Ingress/02-argocd-ingress.yaml
# kubectl apply -f 01-argocd-ingress.yaml

# This YAML file defines a Pod, a Service, and an Ingress exposing the service. 
# It assumes use of nginx-ingress as the Ingress controller. 
# The Pod runs a ArgoCD container which will be accessible over HTTPS at example.com.

# The presence of the cert-manager.io/cluster-issuer annotation in the Ingress resource will be detected by Cert-Manager. 
# It'll use the letsencrypt-staging cluster issuer created earlier to acquire a certificate covering the hostnames defined in the Ingress tls.hosts field.


# 5 Upgrading Cert-Manager
# Cert-Manager releases usually support in-place upgrades with Helm

# helm repo update
# helm upgrade --version <new version> cert-manager jetstack/cert-manager

# 6 Delete Cert-Manager
# URL: https://cert-manager.io/docs/installation/helm/#uninstalling

# helm --namespace cert-manager delete cert-manager
# kubectl delete namespace cert-manager
# kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.crds.yaml