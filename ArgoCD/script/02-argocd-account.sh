# 3 Get The Argo CD Server Password

# Get Password
ARGOCD_ADMIN_PASSWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Check ArgoCD Secret
kubectl get secret -n argocd


# 4 Login Using The CLI
kubectl get svc -n argocd
ARGOCD_SERVER_IP=$(kubectl -n argocd get service argocd-server -o jsonpath='{.spec.clusterIP}')
argocd login $ARGOCD_SERVER_IP:80 --username admin --password $ARGOCD_ADMIN_PASSWD --insecure



# 5 Deploy New User
kubectl apply -f 01-argocd-cm.yaml


# 6 Deploy New RABC
kubectl apply -f 02-argocd-rbac-cm.yaml


# 7 Change New User Password and Login
ARGOCD_USERNAME=xhj
ARGOCD_PASSWORD=SuperSecret12#$ 
argocd account update-password --account $ARGOCD_USERNAME --current-password $ARGOCD_ADMIN_PASSWD --new-password $ARGOCD_PASSWORD
argocd login $ARGOCD_SERVER_IP:80 --username $ARGOCD_USERNAME --password $ARGOCD_PASSWORD --insecure


# 8 Delete admin's Secret
kubectl delete secret argocd-initial-admin-secret -n argocd


# 9 Generate New Token for New User
argocd account generate-token --account $ARGOCD_USERNAME
