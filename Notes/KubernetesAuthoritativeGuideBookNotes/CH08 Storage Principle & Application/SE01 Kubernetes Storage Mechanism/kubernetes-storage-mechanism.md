## Kubernetes Storage Mechanism
容器内部存储的生命周期是短暂的，会随着容器环境的销毁而销毁，具有不稳定性。如果多个容器希望共享同一份存储，则仅仅依赖容器本身是很难实现的。在 Kubernetes 系统中，将对容器应用所需的存储资源抽象为存储卷 (Volume) 概念来解决这些问题。

Volume 是与 Pod 绑定的（独立于容器）与 Pod 具有相同生命周期的资源对象。我们可以将 Volume 的内容理解为目录或文件，容器如需使用某个 Volume，则仅需设置 volumeMounts 将一个或多个 Volume 挂载为容器中的目录或文件，即可访问 Volume 中的数据。Volume 具体是什么类型，以及由哪个系统提供，对容器应用来说是透明。

将 Kubenetes 特定类型的资源对象映射为目录或文件，包括以下类型的资源对象：
- ConfigMap：应用配置
- Secret: 加密数据
- DownwardAPI: Pod 或 Container 的元数据信息
- ServiceAccountToken: Service Account 中的 token 数据
- Projected Volume: 一种特殊的存储卷类型，用于将一个或多个上述资源对象一次性挂载到容器内的同一个目录下


Kubenetes 管理的宿主机本地存储类型如下：
- EmptyDir：临时存储
- HostPath：宿主机目录

持久化存储 (PV) 和网络共享存储类型如下：
- CephFS：一种开源共享存储系统
- Cinder: 一种开源共享存储系统
- CSI：容器存储接口（由存储提供商提供驱动程序和存储管理程序）
- FC （Fibre Channe）：光纤存储设备
- FlexVolume: 一种基于插件式驱动的存储
- Flocker：一种开源共享存储系统
- Glusterfs：一种开源共享存储系统
- iSCSI: iSCSI 存储设备
- Local: 本地持久化存储
- NFS: 网络文件系统
- PersistentVolumeClaim: 简称 PVC，持久化存储的申请空间。
- Portworx Volumes: Portworx 提供的存储服务
- Quobyte Volumes: Quobyte 提供的存储服务
- RBD (Ceph Block Device): Ceph 块存储

存储厂商提供的存储卷类型如下：
- ScaleIO Volumes: DellEMC 的存储设备
- StorageOS: StorageOS 提供的存储服务
- VsphereVolume: VMWare 提供的存储系统

公有云提供的存储卷类型如下：
- AWSElasticBlockStore: AWS 公有云提供的 Elastic Block Store
- AzureDisk: Azure 公有云提供的 Disk
- AzureFile: Azure 公有云提供的 File
- GCEPersistentDisk: GCE 公有云提供的 Persistent Disk

### 将资源对象映射为存储卷

#### 1 ConfigMap


#### 2 Secret


#### 3 Downward API


#### 4 Projected Volume 和 Service Account Token
Projected Volume 是一种特殊的存储卷类型，用于将一个或多个上述资源对象（ConfigMap、Secret、Downward API）一次性挂载到容器内的同一个目录下

从上面的几个示例来看 ，如果 Pod 希望同时挂载 ConfigMap、Secret、Downward APT，则需要设置多个不同类型的 Volume，再将每个 Volume 都挂载为容器内的目录或文件。如果应用程序希望将配置文件和密钥文件放在容器内的同一个目录下，则通过多个 Volume 就无法实现了。为了支持这 需求，Kubernetes 入了一种新的 Projected Volume 存储卷类型，用于将多种配置类数据通过单个 Volume 挂载到容器内的单个目录下

Projected Volume 的一些常见应用场景如下：
- 通过 Pod 的标签生成不同的配置文件，需要使用配置文件，以及用户名和密码，这时需要使用3种资源：ConfigMap、Secrets、Downward API
- 在自动化运维应用中使用配置文件和账号信息时，需要使用 ConfigMap、Secrets
- 在配置文件内使用 Pod 名称 (metadata.name) 记录日志时，需要使用 ConfigMap、Downward API
- 使用某个 Secret 对 Pod 所在命名空间（metadata.namespace）进行加密时，需要使用 Secret、Downward API

Projected Volume 在 Pod 的 Volume 定义中类型为 projected，通过 sources 字段设置一个或多个 ConfigMap、Secret、DownwardAPI、ServiceAccountToken 资源。各种类型的资源的配置内容与被单独设置为 Volume 时基本一样，但有两个不同点。
- 对于 Secret 类型的 Volume，字段名 "secretName" 在 projected.sources.secret 中被改为 "name"
- Volume 的挂载模式 "defaultMode" 仅可以设置在 projected 级别，对于各子项，仍然可以设置各自的挂载模式，使用的字段名为 "mode"

### Node本地存储卷
Kubernetes 管理的 Node 本地存储（Volume）的类型如下：
- EmptyDir: 与 Pod 同生命周期的 Node 临时存储
- HostPath: Node 目录
- Local：基于持久卷（PY）管理的 Node 目录

#### 1 EmptyDir
这种类型的 Volume 将在 Pod 被调度到 Node 时进行创建，在初始状态下目录中是空的，所以命名为“空目录”（Empty Directory），它与 Pod 具有相同的生命周期，当 Pod 被销毁时，Node 上相应的目录也会被删除。同一个 Pod 中的多个容器都可以挂载这种 Volume


#### 2 HostPath
HostPath 类型的存储卷用于将 Node 文件系统的目录或文件挂载到容器内部使用
