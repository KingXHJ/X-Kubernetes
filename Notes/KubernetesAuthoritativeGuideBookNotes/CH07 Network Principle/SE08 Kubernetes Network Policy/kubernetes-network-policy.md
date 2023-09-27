## Kubernetes Network Policy
Network Policy 的主要功能是对 Pod 或者 Namespace 之间的网络通信进行限制和准入控制，设置方式为将目标对象的 label 作为查询条件，设置允许访问或禁止访问的客户端 Pod 表。目前查询条件可以作用于 Pod 和 Namespace 级别

为了使用 Network Policy，Kubernetes 引入了一个新的资源对象 NetworkPolicy，供用户设置 Pod 网络访问策略。但这个资源对象配置的仅仅是策略规则，还需要一个策略控制器（Policy Controller）进行策略规则的具体实现。策略控制器由第三方网络组件提供，目前 Calico、Cilium、Kube-router、Romana、Weave Net 等开源项目均支持网络策略的实现

![Network Policy](./Network%20Policy.png)

### 网络策略的设置说明


### Selector功能说明


### 为命名空间配置默认的网络策略


### 网络策略应用示例


### NetworkPolicy的发票


