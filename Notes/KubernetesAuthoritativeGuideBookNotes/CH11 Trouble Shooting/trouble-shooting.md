为了跟踪和发现在 Kubernetes 集群中运行的容器应用出现的问题，我们常用如下查错方法：
1. 查看 Kubernetes 对象的当前运行时信息，特别是与对象关联的 Event 事件。这些事件记录了相关主题、发生时间、最近发生时间、发生次数及事件原因等，对排查故障非常有价值。此外，通过查看对象的运行时数据，我们还可以发现参数错误、关联错误、状态异常等明显问题。由于在 Kubernetes 中多种对象相互关联，因此这一步可能会涉及多个相关对象的排查间题。
1. 对于服务、容器方面的间题，可能需要深入容器内部进行故障诊断，此时可以通过查看容器的运行日志来定位具体问题。
1. 对于某些复杂问题 例如 Pod 调度这种全局性的问题，可能需要结合集群中每个节点上的 Kubernetes 服务日志来排查。比如搜集 Master 上的 kube-apiserver、kube-schedule、kube-controller-manager 服务日志，以及各个 Node 上的 kubelet、kube-proxy 服务日志，通过综合判断各种信息，就能找到问题的成因并解决问题。