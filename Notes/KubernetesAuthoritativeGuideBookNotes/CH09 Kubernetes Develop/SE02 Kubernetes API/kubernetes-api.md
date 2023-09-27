## Kubernetes API


### Kubernetes API概述
Kubernetes API 是集群系统中的重要组成部分，Kubernetes 中各种资源（对象）的数据都通过该 API 接口被提交到后端的待久化存储（etcd）中，Kubernetes 集群中的各部件之间通过该 API 接口实现解耦合，同时 Kubernetes 集群中一个重要且便捷的管理工具 kubectl 也是通过访问该 API 接口实现其强大的管理功能的。Kubernetes API 中的资源对象都拥有通用的元数据，资源对象也可能存在嵌套现象，比如在一个 Pod 里面嵌套多个 Container。创建一个 API 对象是指通过 API 调用创建一条有意义的记录，该记录一旦被创建，Kubernetes 就将确保对应的资源对象会被自动创建并托管维护

1. kind
    - kind 表明对象有以下三大类别：
        1. 对象（objects）：代表系统中的一个永久资源（实体），例如 Pod、RC、Service、Namespace 及 Node 等。通过操作这些资源的属性，客户端可以对该对象进行创建、修改、删除和获取操作
        1. 列表（list）：一个或多个资源类别的集合。所有列表都通过 items 域获得对象数组，例如 PodLists、ServiceLists、NodeLists。大部分被定义在系统中的对象都有一个返回所有资源集合的端点 ，以及零到多个返回所有资源集合的子集的端点。某些对象有可能是单例对象 （singletons），例如当前用户、系统默认用户等，这些对象没有列表
        1. 简单类别（simple）：该类别包含作用在对象上的特殊行为和非持久实体。该类别限制了使用范围，它有一个通用元数据的有限集合，例如 Binding、Status
1. apiVersion
    - apiVersion 表明 API 的版本号，当前版本默认只支持 v1
1. metadata
    - metadata 是资源对象的元数据定义，是集合类的元素类型，包含一组由不同名称定义的属性。在 Kubernetes 中，每个资源对象都必须包含以下3种 metadata
        1. namespace: 对象所属的命名空间，如果不指定，系统则会将对象置于名为 default 的系统命名空间中
        1. name: 对象的名称，在一个命名空间中名称应具备唯一性
        1. uid: 系统为每个对象都生成的唯一 ID, 符合 RFC 4122 规范的定义
    - 此外，每种对象都还应该包含以下几个重要元数据
        1. labels: 用户可定义的"标签"，键和值都为字符串的 map，是对象进行组织和分类的一种手段，通常用于标签选择器，用来匹配目标对象
        1. annotations: 用户可定义的＂注解＂，键和值都为字符串的 map，被 Kubernetes 内部进程或者某些外部工具使用，用于存储和获取关于该对象的特定元数据
        1. resourceVersion: 用于识别该资源内部版本号的字符串，在用于 Watch 操作时，可以避免在 GET 操作和下一次 Watch 操作之间造成信息不一致，客户端可以用它来判断资源是否改变。该值应该被客户端看作不透明，且不做任何修改就返回给服务端。客户端不应该假定版本信息具有跨命名空间、跨不同资源类别、跨不同服务器的含义。
        1. creationTimestamp：系统记录创建对象时的时间戳，符合 RFC 3339 规范
        1. deletionTimestamp：系统记录删除对象时的时间戳，符合 RFC 3339 规范
        1. selfLink：通过 API 访问资源自身的 URL，例如一个 Pod 的 link 可能是 "/api/v1/namespaces/default/pods/frontend-o8bg4"
1. spec
    - spec 是集合类的元素类型，用户对需要管理的对象进行详细描述的主体部分都在 spec 里给出，它会被 Kubernetes 持久化到 etcd 中保存，系统通过 spec 的描述来创建或更新对象，以达到用户期望的对象运行状态。spec 的内容既包括用户提供的配置设置、默认值、属性的初始化值，也包括在对象创建过程中由其他相关组件（例如 schedulers、auto-scalers）创建或修改的对象属性，比如 Pod 的 ServiceIP 地址。如果 spec 被删除，那么该对象将被从系统中删除
1. status 
    - status 用于记录对象在系统中的当前状态信息，也是集合类元素类型。status在一个自动处理的进程中被持久化，可以在流转的过程中生成。如果观察到一个资源丢失了它的状态，则该丢失的状态可能被重新构造。以 Pod 为例，Pod 的 status 信息主要包括 conditions、containerStatuses、hostIP、phase、podIP、startTime 等，其中比较重要的两个状态属性如下：
        1. phase: 描述对象所处的生命周期阶段，phase 的典型值是 Pending（创建中）、Running、Active（正在运行中）或 Terminated（已终结），这几种状态对于不同的对象可能有轻微的差别，此外，关于当前 phase 附加的详细说明可能被包含在其他域中
        1. condition：表示条件，由条件类型和状态值组成，目前仅有一种条件类型：Ready，对应的状态值可以为 True、False 或 Unknown。一个对象可以具备多种 condition，而 condition 的状态值也可能不断发生变化，condition 可能附带一些信息，例如最后的探测时间或最后的转变时间

### Kubernetes API 版本的演进策略
API 的版本号通常用于描述 API 的成熟阶段，例如：
- v1 表示 GA 稳定版本；
- v1beta3 表示 Beta 版本（预发布版本）；
- v1alpha1 表示 Alpha 版本（实验性的版本）

当某个 API 的实现达到一个新的 GA 稳定版本时（如 v2），旧的 GA 版本（如 v1）和 Beta 版本（例如 v2beta1）将逐渐被废弃，Kubernetes 建议废弃的时间如下：
- 对于旧的 GA 版本（如 v1），Kubernetes 建议废弃的时间应不少于 12 个月或 3 个月大版本 Release 的时间，选择最长的时间
- 对旧的 Beta 版本（如 v2beta1），Kubernetes 建议废弃的时间应不少于 9 个月或 3 个大版本 Release 的时间，选择最长的时间

对旧的 Alpha 版本，则无须等待，可以直接废弃

### API Groups（API组）
为了更容易扩展、升级和演进 API，Kubernetes 将 API 分组为多个逻辑集合，称之为 API Groups，它们支持单独启用或禁用，在不同的 API Groups 中使用不同的版本，允许各组以不同的速度演进，例如 apps/v1、apps/v1beta2、apps/v1beta1 等。API Groups 以 REST URL 中的路径进行定义并区别彼此，每个 API Group 群组都表现为一个以 /apis 为根路径的 rest 路径，不过核心群组 Core 有个专用的简化路径 /api/v1，当前支持以下两类 API Groups
1. Core Groups（核心组），也可以称之为 Legacy Groups。其作为 Kubernetes 核心的 API，在资源对象的定义中被表示为 "apiVersion: v1"，我们常用的资源对象大部分都在这个组里，例如 Container、Pod、ReplicationController、Endpoint、Service、ConfigMap、Secret、Volume等
1. 具有分组信息的 API，以 /apis$GROUP_NAME/$VERSION URL 路径进行标识，例如 apiVersion: batch/v1、apiVersion: extensions:v1beta1、apiVersion: apps/v1beta1 等。比如 /apis/apps/v1 在 apiversion 字段中的格式为 "$GROUP_NAME/$VERSION"。下面是常见的一些分组说明：
    - apps/v1：是 Kubernetes 中最常见的 API 组，其中包含许多核心对象，主要与用户应用的发布、部署有关，例如 Deployments，RollingUpdates 和 ReplicaSets
    - extensions/VERSION：扩展 API 组，例如 DaemonSets、ReplicaSet 和 Ingresses都在此版本中有重大更改
    - batch/VERSION：包含与批处理和类似作业的任务相关的对象，例如 Job，包括 v1 与 v1beta1 两个版本
    - autoscaling/VERSION：包含与 HPA 相关的资源对象，目前有稳定的 v1 版本
    - certificates.k8s.io/VERSION：包含集群证书操作相关的资源对象
    - rbac.authorization.k8s.io/v1：包含 RBAC 权限相关的资源对象
    - policy/VERSION：包含 Pod 安全性相关的资源对象
    如果需要实现自定义的资源对象及相应的 API，则使用 CRD 进行扩展是最方便的

### API REST的方法说明



### API Server相应说明

