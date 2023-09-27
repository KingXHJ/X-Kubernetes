# URL: https://k8s-docs.github.io/cert-manager-docs/concepts/certificate/#_1
# URL: https://k8s-docs.github.io/cert-manager-docs/troubleshooting/acme/#404

echo "1. Checking secret"
kubectl get secret -n argocd
echo -e "\n\n"

echo "2. Checking clusterissuer"
kubectl get clusterissuer -n argocd
echo -e "\n\n"

echo "3. Checking certificate"
kubectl get certificate -n argocd
echo -e "\n\n"

echo "4. Checking certificaterequest"
kubectl get certificateRequest -n argocd
echo -e "\n\n"

echo "5. Checking order"
kubectl get order -n argocd
echo -e "\n\n"

echo "6. Checking challenge"
kubectl get challenge -n argocd
echo -e "\n\n"