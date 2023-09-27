echo '--------------------Client VM---------------'

echo '-------------------- 1 IP table --------------------'

lsmod | grep br_netfilter
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system


echo '-------------------- 2 Install kubectl --------------------'

sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl

# sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo mkdir /etc/apt/keyrings/

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list



sudo apt-get update && sudo apt-get install -y kubectl
sudo apt-mark hold kubectl


cat <<EOF | sudo tee -a /etc/hosts
10.230.0.10 controller-vm
10.230.0.20 worker-0
EOF

mkdir -p $HOME/.kube

scp cka@controller-vm:$HOME/.kube/config $HOME/.kube

kubectl get nodes 

# cat <<EOF | sudo tee -a /etc/hosts
# 10.230.0.15 cka-client
# 10.230.0.10 controller-vm
# 10.230.0.20 worker-0
# EOF
