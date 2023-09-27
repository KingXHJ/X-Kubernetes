## Common Problem

### 由于无法下载 pause 镜像导致 Pod 一直处于 Pending 状态


### Pod创建成功，但 RESTARTS 数量持续增加


### 通过服务名无法访问服务
1. 查看 Service 的后端 Endpoint 是否正常
1. 查看 Service 的名称能否被正确解析为 ClusterIP 地址
1. 查看 kube-proxy 的转发规则是否正确
