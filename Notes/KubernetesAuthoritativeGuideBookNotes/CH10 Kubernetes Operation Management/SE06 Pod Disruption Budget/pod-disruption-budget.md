## Pod Disruption Budget（主动驱逐保护）
在 Kubernetes 集群运行过程中，许多管理操作都可能对 Pod 进行主动驱逐，“主动”一词意味着这一操作可以安全地延迟一段时间，目前主要针对以下两种场景
- 节点维护或升级时（kubectl drain）
- 对应用的自动缩容操作（autoscaling down）

作为对比，由于节点不可用（Not Ready）导致的 Pod 驱逐就不能被称为主动了，但 Pod 的主动驱逐行为可能导致某个服务对应的 Pod 实例全部或大部分被“消灭＂，从而引发业务中断或业务 SLA 降级，而这是违背 Kubernetes 的设计初衷的。因此需要一种机制来避免我们希望保护的 Pod 被主动驱逐，这种机制的核心就是 PodDisruptionBudget。通过使用 PodDisruptionBudget，应用可以保证那些会主动移除 Pod 的集群操作永远不会在同一
时间停掉太多 Pod（从而导致服务中断或者服务降级等）