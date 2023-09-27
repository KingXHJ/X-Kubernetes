# kubectl patch pod kube-apiserver -n kube-system --type strategic --patch-file 01-Modified-kube-apiserver.yaml
# kubectl patch pod kube-apiserver-controller-vm -n kube-system --type strategic --patch-file 01-Modified-kube-apiserver.yaml

# 追加参数貌似只能手动去做了

# Static Pod 的配置文件被修改后，立即生效。
# Kubelet 会监听该文件的变化，当您修改了 /etc/kubernetes/manifests/kube-apiserver.yaml 文件之后，kubelet 将自动终止原有的 kube-apiserver-{nodename} 的 Pod，并自动创建一个使用了新配置参数的 Pod 作为替代。
# 如果您有多个 Kubernetes Master 节点，您需要在每一个 Master 节点上都修改该文件，并使各节点上的参数保持一致。
# kubectl apply -f /etc/kubernetes/manifests/kube-apiserver.yaml

# 重启 kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet