## Support For GPUs
Kubernetes 1.8 版本开始，引入了 Device Plugin（设备插件）模型，为设备提供商提供了一种基于插件的、无须修改 kubelet 核心代码的外部设备启用方式，设备提供商只需在计算节点上以 DaemonSet 方式启动一个设备插件容器供 kubelet 调用，即可使用外部设备。目前支持的设备类型包括 GPU、高性能 NIC 卡、FPGA、InfiniBand 等，关于设备插件的说明详见官方文档。


### 环境准备



### 在容器中使用 GPU 资源
1. 为 Node 设置合适的 Label 标签
1. 设置 Node Selector 指定调度 Pod 到目标 Node 上



### 发展趋势
