# https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

# Get Helm Repository Info
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create new namespace
kubectl create namespace prometheus-operator

# Install Helm Chart
# helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack
helm install prometheus-operator prometheus-community/kube-prometheus-stack -n prometheus-operator

# Need to be set up ingress for Prometheus

# Test Prometheus
# kubectl port-forward -n prometheus-operator svc/prometheus-operator-grafana 3000:80

# Delete Prometheus
# helm uninstall prometheus-operator -n prometheus-operator