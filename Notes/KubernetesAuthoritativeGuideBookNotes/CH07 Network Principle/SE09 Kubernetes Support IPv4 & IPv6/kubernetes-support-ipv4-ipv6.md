## Kubernetes Support IPv4 & IPv6
在 Kubernetes 集群中启用 IPv4 和 IPv6 双栈可以提供以下功能：
- 为 Pod 分配一个 IPv4 地址和一个 IPv6 地址
- 为 Service 分配一个 IPv4 地址或一个 IPv6 地址，只能使用一种地址类型
- Pod 可以同时通过 IPv4 地址和 IPv6 地址路由到集群外部 (egress) 的网络（如 Internet）

为了在 Kubernetes 集群中使用 IPv4 和 IPv6 双栈功能，需要满足以下前提条件：
- 使用 Kubernetes 1.16 及以上版本
- Kubernetes 集群的基础网络环境必须支持双栈网络，即提供可路由的 IPv4 和 IPv6 网络接口
- 支持双栈的网络插件，例如 Calico 或 Kubenet

### 为Kubernetes集群启用IPv4和IPv6双栈



### Pod双栈IP地址验证



### Service双栈IP地址验证
对于 Service 来说，一个 Service 只能设置 IPv4 或者 IPv6 一种 IP 地址类型，这需要在 Service 的 YAML 定义中通过 ipFamily 字段进行设置。该字段是可选配置，如果不指定，则使用 kube-controller-manager 服务 --service-cluster-ip-range 参数设置的第 1 个 IP 地址的地址类型。ipFamily 字段可以设置的值为 “IPv4" 或 “IPv6”


