## Pod Security Policy
专门用于Pod的安全管理

### PodSecurityPolicy的工作机制
注意，在开启PodSecurityPolicy准入控制器后，系统中还没有任何PodSecurityPolicy策略配置时，Kunernetes默认不允许创建任何Pod，需要管理员创建适合的PodSecurityPolicy策略和相应的RBAC授权策略，Pod才能创建成功

![podsecuritypolicy.yaml](./podsecuritypolicy.yaml)

### PodSecurityPolicy配置详解
1. 特权模式
1. 宿主机命名空间（namespace）相关
1. 存储卷（volume）和文件系统相关
1. FlexVolume驱动相关
1. 用户和组相关配置
1. 提升权限（Privilege Escalation）相关配置
1. Linux能力相关配置
1. SELinux
1. 其他Linux安全相关配置


### PodSecurityPolicy策略示例
1. 特权策略
1. 受限策略
1. 基线（baseline）策略

### PodSecurityPolicy的RABC授权
（有一个完整的示例）

### Pod安全设置（Security Context）详解
1. Pod级别的Security Context安全设置，作用于该Pod内的全部容器
1. Pod的Volume权限修改策略
1. Container级别的安全设置，作用于特定的容器
1. 为Container设置可用的Linux能力（Capabilities）
1. 为Pod或Container设置SELinux标签