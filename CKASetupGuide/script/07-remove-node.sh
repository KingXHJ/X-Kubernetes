# 通知集群停止对这个节点的调度，并且驱逐已经部署在该节点上的pod，执行
# kubectl drain ubuntu-jetsonnano --delete-local-data --force --ignore-daemonsets
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets


# 删除节点
# kubectl delete node ubuntu-jetsonnano
kubectl delete node <node name>

# 在已经移除的节点 scm-node-prd-01上执行 kubeadm reset：
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config
sudo rm -rf /etc/kubernetes/
sudo kubeadm reset