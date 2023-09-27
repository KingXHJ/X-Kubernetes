## Support For Windows Containers
将一台 Windows Server 服务器部署为 Kubernetes Node，需要的组件包括 Docker、Node组件（kubelet 和 kube-proxy）和 CNI 网络插件。本例以 Flannel CNI 插件部署容器 Overlay 网络，要求在 Linux Kubernetes 集群中已经部署好 Flannel 组件。注意：Windows Server 仅能作为 Node 加入 Kubernetes 集群中，集群的 Master 仍需在 Linux 环境中运行

### 在 Windows Server 上安装 Docker


### 在 Windows Server 上部署 Kubernetes Node 组件
1. 下载和安装 Kubernetes Node 所需的服务
1. 下载 pause 镜像
1. 从 Linux Node 上复制 kubeconfig 配置文件和客户端 CA 证书
1. 下载 Windows Node 所需的脚本和配置文件
1. 下载 CNI 相关的脚本和配置文件
1. 修改 Powershell 脚本中的配置参数
    1. start.ps1脚本
    1. 通过环境变量设置 Node 名称
    1. helper.psm1脚本
    1. register-svc.ps1 脚本
    1. start-kubeproxy.ps1 脚本
1. 启动 Node
    1. 启动 flanneld，设置 CNI 网络
    1. 打开一个新的 powershell 窗口来启动 kubelet
    1. 打开一个新的 powershell 窗口来启动 kube-proxy
    1. 在服务启动成功之后，在 Master 上查看新加入的 Windows Node


### 在 Windows Server 上部署容器应用和服务
1. 部署 win-server 容器应用和服务
1. 在 Linux 环境中访问 Windows 容器服务
    1. 在 Linux 容器内访问 Windows 容器服务，通过 Windows Pod IP 访问成功
    1. 在 Linux 容器内访问 Windows 容器服务，通过 Windows 容器 Service IP 访问成功
    1. 在 Linux 容器内访问 Windows 容器服务，通过 Windows Server 的 IP 和 NodePort 访问成功
1. 在 Windows Server 主机上访问 Windows 容器服务
    1. 在 Windows Server 主机上访问 Windows 容器服务，通过 Windows Pod IP 访问成功
    1. 在 Windows Server 主机上访问 Windows 容器服务，通过 Windows 容器 Service IP 访问成功
    1. 在 Windows Server 主机上访问 Windows 容器服务，通过 Windows Server 的 IP 和 NodePort 无法成功（这是 Windows 网络模型的一个限制）
1. 在 Windows 容器内访问 Linux 容器服务（示例中 Web 服务巳部署）
    1. 在 Windows 容器内访问 Linux 容器服务，通过 Linux Pod IP 访问成功
    1. 在 Windows 容器内访问 Linux 容器服务，通过 Linux 服务 IP 访问成功


### Kubernetes 支持的 Windows 容器特性、限制和发展趋势
1. Kubernetes 管理功能
    1. Pod
    1. 支持的控制器类型包括 ReplicaSet、ReplicationController、Deployments、StatefulSets、DaemonSet、Job 和 CronJob
    1. 服务
    1. 其他
1. 容器运行时
1. 持久化存储
1. 网络
1. 已知的功能限制
    1. 控制平面
    1. 计算资源管理
    1. 暂不支持的特性
    1. 存储资源管理
    1. 网络资源管理
1. 计划增强的功能
