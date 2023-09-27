## Kubernetes Resource Manage



### 计算资源管理
1. 详解 Requests 和 Limits 参数
    1. CPU
    1. Memory
1. 基于Requests和Limits的Pod调度机制
1. Requests和Limits的背后机制
    1. spec.container[].resources.requests.cpu
    1. spec.container[].resources.limits.cpu
    1. spec.container[].resources.requests.memory
    1. spec.container[].resources.limits.memory
1. 计算资源使用情况监控
1. 计算资源常见问题分析
    1. Pod状态为Pending，错误信息为FailedScheduling
    1. 容器被强行终止（Terminated）
1. 对大内存页（Huge Page）资源的支持



### 资源配置范围管理（LimitRange）
1. 创建一个命名空间
1. 为命名空间设置LimitRange
1. 创建Pod时触发LimitRange限制


### 资源服务质量管理（Resource QoS）
1. Requests 和 Limits对不同计算资源类型的限制机制
    1. 可压缩资源
    1. 不可压缩资源
1. 对调度策略的影响
1. 服务质量等级（QoS Classes）
    - 3个QoS等级：  
        1. Guaranteed（完全可靠的）
        1. Burstable（弹性波动、较可靠的）
        1. BestEffort（尽力而为、不大可靠的）
    1. Guaranteed
    1. BestEffort
    1. Burstable   
    1. Kubernetes QoS的工作特点
    1. OOM计分规则
    1. QoS的演进
        1. 不支持内存 Swap，当前的 QoS 策略都假定了主机不启用内存 Swap
        1. 缺乏更丰富的 QoS 策略，当前的 QoS 策略都是基于 Pod 的资源配置 (Requests 和 Limits) 来定义的，而资源配置本身又承担着对 Pod 资源管理和限制的功能

### 资源配额管理（Resource Quotas）
1. 在Master中开启资源配额选型
    1. 计算资源配额（Compute Resource Quota）
    1. 存储资源配额（Volume Count Quota）
    1. 对象数量配额（Object Count Quota）
1. 配额的作用域（Quota Scopes）
1. 在资源配额（ResourceQuota）中设置 Requests 和 Limits
1. 资源配额的定义
1. 资源配额与集群资源总量的关系



### ResourceQuota 和 LimitRange 实践
1. 创建命名空间
1. 设置限定对象数量的资源配额
1. 设置限定计算资源的资源配额
1. 配置默认的Requests和Limits
1. 指定资源配额的作用域
1. 资源管理小结
    - Kubernetes 中资源管理的基础是容器和 Pod 的资源配篮（Requests Limits）。容器的资源配置指定了容器请求的资源和容器能使用的资源上限，Pod 的资源配置则是 Pod 中所有容器的资源配置总和上限。
    - 通过资源配额机制，我们可以对命名空间中所有 Pod 使用资源的总证进行限制，也可以对这个命名空间中指定类型的对象的数量进行限制。使用作用域可以让资源配额只对符合特定范图的对象加以限制，因此作用域机制可以使资源配额的策略更加丰富、灵活
    - 如果需要对用户的 Pod 或容器的资源配置做更多的限制，则可以使用资源配置范围（LimitRange）来达到这个目的。LimitRange 可以有效限制 Pod 和容器的资源配置的最大、最小范围，也可以限制 Pod 和容器的 Limits 与 Requests 的最大比例上限，LimitRange 还可以为 Pod 中的容器提供默认的资源配置
    - Kubernetes 基于 Pod 的资源配置实现了资源服务质量（QoS）。不同 QoS 级别的 Pod在系统中拥有不同的优先级：高优先级的 Pod 有更高的可靠性，可以用于运行对可靠性要求较高的服务；低优先级的 Pod 可以实现集群资源的超售，有效提高集群资源利用率
    - 上面的多种机制共同组成了当前版本 Kubernetes 的资源管理体系。这个资源管理体系可以满足大部分资源管理需求。同时，Kubernetes 的资源管理体系仍然在不停地发展和进化，对于目前无法满足的更复杂、更个性化的需求，我们可以继续关注 Kubernetes 未来的发展和变化
    - 下面对计算资源以外的其他几种资源的管理方式进行说明，包括 Pod 内多个容器的共享进程命名空间、PID 资源管理、节点的 CPU 资源管理策略和拓扑管理器



### Pod中多个容器共享进程命名空间



### PID资源管理



### 节点的CPU管理策略
1. None策略
1. Static
1. 节点 CPU 管理策略示例



### 拓扑管理器
1. 拓扑管理器的工作原理
1. 启用拓扑管理器
1. 拓扑管理器策略
1. Pod与拓扑管理器策略的交互示例
1. 拓扑管理器当前的局限性
    - 拓扑管理器在当前有以下局限性：
        1. 拓扑管理器所能处理的最大 NUMA 节点数量为 8 个。如果 NUMA 节点数虽超过 8 个，则尝试枚举所有可能的 NUMA 亲和性并为之生成建议时，可能会发生状态爆炸(State Explosion)
        1. 调度器无法做到拓扑感知，因此可能会调度 Pod 到某个节点上，但由于拓扑管理器的原因导致 Pod 无法在该节点上运行
        1. 目前仅有设备管理器（Device Manage）和 CPU 管理器（CPU Manager）两个组件适配了拓扑管理器的 HintProvider 接口。这意味着 NUMA 对齐只能针对 CPU 管理器和设备管理器所管理的资源进行实现。内存（Memory）和巨页（Hugepage）在拓扑管理器决定 NUMA 对齐时都还不会被考虑在内