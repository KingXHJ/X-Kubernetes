## Check Kubernetes Service Log
如果在 Linux 系统上安装 Kubernetes, 并且使用 systemd 系统管理 Kubernetes 服务，那么 systemd journal 系统会接管服务程序的输出日志。在这种环境中，可以通过使用 systemd status 或 journalctl 工具来查看系统服务的日志。

在大多数情况下，我们从 WARNING 和 ERROR 级别的日志中就能找到问题的成因，但有时还需要排查 INFO 级别的日志甚至 DEBUG 级别的详细日志。此外，etcd 服务也属于 Kubernetes 集群的重要组成部分，所以不能忽略它的日志

如果某个 Kubenetes 对象存在问题，则可以用这个对象的名字作为关键字搜索 Kubernetes 的日志来发现和解决问题。在大多数情况下，我们遇到的主要是与 Pod 对象相关的问题，比如无法创建 Pod、Pod 启动后就停止或者 Pod 副本无法增加，等等。此时，可以先确定 Pod 在哪个节点上，然后登录这个节点，从 kubelet 的日志中查询该 Pod 的完整日志，然后进行间题排查。对于与 Pod 扩容相关或者与 RC 相关的问题，则很可能在 kube-controller-manager 及 kube-scheduler 的日志中找出问题的关键点

另外，kube-proxy 经常被我们忽视，因为即使它意外停止，Pod 的状态也是正常的，但会导致某些服务访问异常。这些错误通常与每个节点上的 kube-proxy 服务有着密切的关系。遇到这些问题时，首先要排查 kube-proxy 服务的日志，同时排查防火墙服务，要特别留意在防火墙中是否有人为添加的可疑规则