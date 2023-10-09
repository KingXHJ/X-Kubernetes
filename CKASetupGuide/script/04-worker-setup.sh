# run this in master to ge the join token 
# sudo kubeadm token create --print-join-command

sudo rm /etc/containerd/config.toml

sudo systemctl restart containerd

# 注：安装kubelet完成后，kubelet是不启动的，不能直接systemctl start kubelet，加入节点或初始化为master后即可启动成功

#sudo kubeadm join 10.230.0.10:6443 --token g0fibk.lkzwifjkc7evhbcd \
#        --discovery-token-ca-cert-hash sha256:f911271ae9a7760dec1ec3cdf73802bc9758a2a51ec2e20ce7e0809a00b80952
# kubeadm token list 

# Sample 
# kubeadm token create --print-join-command
# kubeadm join 10.230.0.10:6443 --token bqfs2e.29l1ii0l4gpqxt98 \
#     --discovery-token-ca-cert-hash sha256:bf55a001265f6ae52f7f4f1c51486c240ee302ccdf20c751785f48723e36fbb8 
