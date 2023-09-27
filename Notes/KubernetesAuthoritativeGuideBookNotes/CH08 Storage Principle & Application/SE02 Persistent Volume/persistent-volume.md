## Persistent Volume
在 Kubenetes 中，对存储资源的管理方式与计算资源（CPU/内存）截然不同。为了能够屏蔽底层存储实现的细节，让用户方便使用及管理员方便管理，Kubenetes 从 1.0 版本开始就引入了 Persistent Volume (PV) 和 Persistent Volume Claim (PVC) 两个资源对象来实现存储管理子系统。

PV（持久卷）是对存储资源的抽象，将存储定义为一种容器应用可以使用的资源。PV 由管理员创建和配置，它与存储提供商的具体实现直接相关，例如 GlusterFS、iSCSI、RBD 或 GCE 或 AWS 公有云提供的共享存储，通过插件式的机制进行管理，供应用访问和使用。除了 EmptyDir 类型的存储卷，PV 的生命周期独立于使用它的 Pod。

PVC 则是用户对存储资源的一个申请。就像 Pod 消耗 Node 的资源一样，PVC 消耗 PV 资源。PVC 可以申请存储空间的大小 (size) 和访问模式（例如 ReadWriteOnce、ReadOnlyMany 或 ReadWriteMany）

使用 PVC 申请的存储空间可能仍然不满足应用对存储设备的各种需求。在很多情况下，应用程序对存储设备的特性和性能都有不同的要求，包括读写速度、并发性能、数据冗余等要求，Kubernetes 1.4 版本开始引入了一个新的资源对象 StorageClass，用于标记存储资源的特性和性能，根据 PVC 的需求动态供给合适的 PV 资源。到Kubemetes 1.6版本时，StorageClass 和存储资源动态供应的机制得到完善，实现了存储卷的按需创建，在共享存储的自动化管理进程中实现了重要的一步。

通过 StorageClass 的定义，管理员可以将存储资源定义为某种类别（Class），正如存储设备对于自身的配置描述（Profile），例如快速存储、慢速存储、有数据冗余、无数据冗余等。用户根据  StorageClass 的描述就可以直观地得知各种存储资源的特性，根据应用对存储资源的需求去申请存储资源了

Kubernetes 从1.9版本开始引入容器存储接口 Container Storage Interface (CSI) 机制，目标是在 Kubernetes 和外部存储系统之间建立一套标准的存储管理接口，具体的存储驱动程序由存储提供商在 Kubernetes 之外提供，并通过该标准接口为容器提供存储服务，类似于 CRI（容器运行时接口）和 CNI（容器网络接口），目的是将 Kubernetes 代码与存储相关代码解耦

### PV 和 PVC 的工作原理

![PV & PVC](./PV%20&%20PVC.png)

1. 资源供应
    Kubernetes 支持两种资源供应模式：静态模式（Static）和动态模式（Dynamic），资源供应的结果就是将适合的 PV 与 PVC 成功绑定：
    - 静态模式：集群管理员预先创建许多 PV，在 PV 的定义中能够体现存储资源的特性
    - 动态模式：集群管理员无须预先创建 PV，而是通过 StorageClass 的设置对后端存储资源进行描述，标记存储的类型和特性。用户通过创建 PVC 对存储类型进行申请，系统将自动完成 PV 的创建及与 PVC 绑定。如果 PVC 声明的 Class 为空 ""，则说明 PVC 不使用动态模式。另外，Kubernetes 支持设置集群范围内默认的 StorageClass 设置，通过 kube-apiserver 开启准入控制器 DefaultStorageClass，可以为用户创建的 PVC 设置一个默认的存储类 StorageClass
1. 资源绑定
1. 资源使用
1. 资源回收（Reclaiming）
    1. Retain（保留数据）
    1. Delete（删除数据）
    1. Recycle（弃用）
1. 

### PV详解
[pv.yaml](./pv.yaml)

1. 存储容量（Capacity）
1. 存储卷模式（Volume Modes）
1. 访问模式（Access Modes）
1. 存储类别（Class）
1. 回收策略（Reclaim Policy）
1. 挂载选项（Mount Options）
1. 节点亲和性（Node Affinity）

某个 PV 在生命周期中可能处千以下4个阶段 (Phase) 之一：
1. Available：可用状态，还未与某个 PVC 绑定
1. Bound：已与某个 PVC 绑定
1. Released：与之绑定的 PVC 已被删除，但未完成资源回收，不能被其他 PVC 使用
1. Failed: 自动资源回收失败

### PVC详解
[pvc.yaml](./pvc.yaml)

### Pod使用PVC
在 PVC 创建成功之后，Pod 就可以以存储卷（Volume）的方式使用 PVC 的存储资源了。PVC 受限于命名空间，Pod 在使用 PVC 时必须与 PVC 处于同一个命名空间。

Kubenetes 为 Pod 挂载 PVC 的过程如下：系统在 Pod 所在的命名空间中找到其配置 PVC，然后找到 PVC 绑定的后端 PV，将 PV 存储挂载到 Pod 所在 Node 的目录下，最后将 Node 的目录挂载到 Pod 的容器内

注意：
1. 使用裸块设备 PVC 的 Pod 定义如下。与文件系统模式 PVC 的用法不同，容器不使用 volumeMounts 设置挂载目录，而是通过 volumeDevices 字段设置块设备的路径 devicePath
1. subPath 中的路径名称不能以 "/" 开头，需要用相对路径的形式


### StorageClass详解
StorageClass 作为对存储资源的抽象定义，对用户设置的 PVC 申请屏蔽后端存储的细节，一方面减少了用户对于存储资源细节的关注，另一方面减轻了管理员手工管理 PV 工作，由系统自动完成 PV 的创建和绑定，实现动态的资源供应。基于 StorageClass 的动态资源供应模式将逐步成为云平台的标准存储管理模式

StorageClass 资源对象的定义主要包括名称、后端存储的提供者（provisioner）、后端存储的相关参数配置和回收策略。StorageClass 的名称尤为重要，将在创建 PVC 时引用，管理员应该准确命名具有不同存储特性的 StorageClass

StorageClass 一旦被创建，则无法修改。如需更改，则只能删除原 StorageClass 资源对象并重新创建

1. 存储提供者（Provisioner）
1. 资源回收策略（Reclaim Policy）
1. 是否允许存储扩容（Allow Volume Expansion）
1. 挂载选项（Mount Options）
1. 存储绑定模式（Volume Binding Mode）
1. 存储参数（Parameters）
1. 设置默认的StorageClass