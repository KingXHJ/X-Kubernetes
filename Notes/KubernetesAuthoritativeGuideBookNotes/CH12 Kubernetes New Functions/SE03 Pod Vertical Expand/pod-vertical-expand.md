## Pod Vertical Expand
除了 HPA（Pod 水平扩展功能），Kubernetes 仍在继续开发一些新的互补的 Pod 自动扩缩容功能，将其统一放在 Kubernetes Autoscaler 的 GitHub 代码库进行维护。目前有以下几个正在开发的项目：
- ClusterAutoScaler：主要用于公有云上的 Kubernetes 集群，目前已经覆盖常见的公有云，包括 GCP、AWS、Azure、阿里云、华为云等，其核心功能是自动扩容 Kubernetes 集群的节点，以应对集群资源不足或者节点故障等情况
- Vertical Pod Autoscaler：简称 VPA，目前仍在快速演进，主要与 HPA 互补，提供 Pod 垂直扩缩容的能力，这也是本节讲解的主要内容
- Addon Resizer：是 VPA 的简化版，可方便我们体验 VPA 的新特性。

### VPA详解
简单来说，VPA 主要是想办法找出目标 Pod 运行期间所需的最少资源。并且将目标 Pod 的资源请求改为它所建议的数值，这样一来，容器既不会有资源不足的风险，又最大程度地提升了资源利用率。其设计思路也不难理解，如下所述：
1. VPA 会通过 Metrics Server 获取目标 Pod 运行期间的实时资源度量指标，主要是 CPU 和内存使用指标
1. 将这些数据汇聚处理后存放在 History Storage 组件中
1. History Storage 组件中的历史数据与 Metrics Server 里的实时数据会一起被 VPA 的 Recommender 组件使用。Recommender 组件会结合推荐模型 Recommendation model 推导出 Pod 资源请求的合理建议值。目前实现的推荐模型比较简单：假设内存和 CPU 使用率是独立的随机变量，其分布等于在过去 N 天中观察到的分布（推荐 N=8，以捕获每周峰值）。未来更先进的模型可能会尝试检测趋势、周期性及其他与时间相关的模式
1. 一旦 Recommender 计算出目标 Pod 的新推荐值，若这个推荐值与 Pod 当前实际配置的资源请求明显不同，VPA Updater 组件就可以决定更新 Pod。Pod 的更新有以下两种方式：
    1. 通过 Pod 驱逐（Pod Eviction），让 Pod 控制器如 Deployment、ReplicaSet 等来决定如何销毁目标 Pod 并重建 Pod 副本
    1. 原地更新 Pod 实例（In-place updates），目标 Pod 并不销毁，而是直接修改目标 Pod 的资源配置数据并立即生效。这也是 VPA 的一个亮点特性


如果我们不放心 VPA 自动修改 Pod 的资源配置信息，则可以将 UpdateMode 设置为 Off，这时可以通过命令行得到 VPA 给出的建议值。VPA 还有一个重要的组件——VPA Admission Controller，它会拦截 Pod 的创建请求，如果该 Pod 对应的 UpdateMode 不是 Off，则它会用 Recommender 推荐的值改写 Pod 中对应的 Spec 内容。在目前的版本中，Pod 不必通过 VPA 的准入控制"修正"就能被正常调度，但在未来的版本中可能考虑增加强制性要求，比如某种 Pod 必须要经过 VPA 的修正才能被调度，如果该 Pod 没有定义对应的 VerticalPodAutoscaler，则 VPA Admission Controller 可以拒绝该 Pod 的创建请求

VPA 与 HPA 是否可能共同作用在同一个 Pod 上？从理论上来说，的确存在这种可能性，比如：CPU 密集的负载（Pod）可以通过 CPU 利用率实现水平扩容，同时通过 VPA 缩减内存使用量；I/O 密集的负载（Pod）可以基于 I/O 吞吐量实现水平扩容，同时通过 VPA 缩减内存和 CPU 使用量

但是，实际应用是很复杂的，因为 Pod 副本数量的变动不仅影响到瓶颈资源的使用情况，也影响到非瓶颈资源的使用情况，其中有一定的因果耦合关系。此外，VPA 目前的设计实现没有考虑到多副本的影响，在未来扩展后有可能达到 HPA 与 VPA 双剑合璧的新境界


### 安装 Vertical Pod Autoscalar



### 为 Pod 设置垂直扩缩容



### 注意事项
- VPA 对 Pod 的更新会造成 Pod 的重新创建和调度
- 对于不受控制器支配的 Pod，VPA 仅能在其创建时提供支持
- VPA 的准入控制器是一个 Webhook，可能会和其他同类 Webhook 存在冲突，从而导致无法正确执行
- VPA 能够识别多数内存不足的问题，但并非全部
- 尚未在大规模集群上测试 VPA 的性能
- 如果多个 VPA 对象都匹配同一个 Pod，则会造成不可预知的后果
- VPA 目前不会设置 limits 字段的内容