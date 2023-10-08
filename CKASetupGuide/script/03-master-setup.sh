# everything is like worker node plus 
# run worker-setup.sh in control plane as well

sudo rm /etc/containerd/config.toml

sudo systemctl restart containerd

# Raspberry Pi 兼容性问题
echo 'net.ifnames=0 dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline cgroup_enable=memory cgroup_memory=1 rootwait fixrtc' | sudo tee /boot/firmware/cmdline.txt
reboot

# run kubeadm
# sudo kubeadm init --kubernetes-version=v1.24.15 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=<本机IP地址>
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.10.1.194

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Pod network https://www.weave.works/docs/net/latest/kubernetes/kube-addon/
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubectl get nodes

kubectl get pods --all-namespaces

# this output will have two instructions. 
# 1. Move Kubeconfig file
# 2. attching new node 
#--------- Sample --------------

# To start using your cluster, you need to run the following as a regular user:

#   mkdir -p $HOME/.kube
#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#   sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Alternatively, if you are the root user, you can run:

#   export KUBECONFIG=/etc/kubernetes/admin.conf

# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#   https://kubernetes.io/docs/concepts/cluster-administration/addons/

# Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join 10.230.0.10:6443 --token j6lkpd.fmk3y8yexddsppfk --discovery-token-ca-cert-hash sha256:10a42d6d8e9a9ff948ccb313336c34717107a40ce370c29677dee3a154dc8c6b
