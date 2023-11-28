# Get The Argo CD Server Password

# Get Password
ARGOCD_ADMIN_PASSWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Check ArgoCD Secret
kubectl get secret -n argocd


# Login admin Using The CLI
kubectl get svc -n argocd
ARGOCD_SERVER_IP=$(kubectl -n argocd get service argocd-server -o jsonpath='{.spec.clusterIP}')
argocd login $ARGOCD_SERVER_IP:80 --username admin --password $ARGOCD_ADMIN_PASSWD --insecure


# Update admin's Password
ARGOCD_ADMIN_NEW_PASSWD=SuperSecret12#$
argocd account update-password --account admin --current-password $ARGOCD_ADMIN_PASSWD --new-password $ARGOCD_ADMIN_NEW_PASSWD
# argocd account generate-token --account admin
argocd login $ARGOCD_SERVER_IP:80 --username admin --password $ARGOCD_ADMIN_NEW_PASSWD --insecure


# Delete admin's Secret
kubectl delete secret argocd-initial-admin-secret -n argocd


# Deploy New User
kubectl apply -f 01-argocd-cm.yaml


# Deploy New RABC
kubectl apply -f 02-argocd-rbac-cm.yaml


# Change ALL User Password and Login
ARGOCD_USERNAME_1=kingxhj
ARGOCD_PASSWORD_1=SuperSecret12#$
argocd account update-password --account $ARGOCD_USERNAME_1 --current-password $ARGOCD_ADMIN_NEW_PASSWD --new-password $ARGOCD_PASSWORD_1
argocd login $ARGOCD_SERVER_IP:80 --username $ARGOCD_USERNAME_1 --password $ARGOCD_PASSWORD_1 --insecure
argocd account generate-token --account $ARGOCD_USERNAME_1

argocd login $ARGOCD_SERVER_IP:80 --username admin --password $ARGOCD_ADMIN_NEW_PASSWD --insecure

ARGOCD_USERNAME_2=z4hd
ARGOCD_PASSWORD_2=SuperSecret12#$
argocd account update-password --account $ARGOCD_USERNAME_2 --current-password $ARGOCD_ADMIN_NEW_PASSWD --new-password $ARGOCD_PASSWORD_2
argocd login $ARGOCD_SERVER_IP:80 --username $ARGOCD_USERNAME_2 --password $ARGOCD_PASSWORD_2 --insecure
argocd account generate-token --account $ARGOCD_USERNAME_2

argocd login $ARGOCD_SERVER_IP:80 --username admin --password $ARGOCD_ADMIN_NEW_PASSWD --insecure


# Set ArgoCD into the "insecure" mode
kubectl patch deployment argocd-server -n argocd --type merge --patch-file 03-argocd-insecure.yaml
# 其中，“image: quay.io/argoproj/argocd:v2.8.4” 是argocd-server的镜像，可以根据实际情况进行修改。但是必须添加！！！