# Kubernetes Setup


## 目录
- [1 Kubeadm 部署集群](#1-kubeadm-部署集群)
- [2 从 0 到 1 搭建一个完整的 Kubernetes 集群](#2-从-0-到-1-搭建一个完整的-kubernetes-集群)
- [3 牛刀小试：我的第一个容器化应用](#3-牛刀小试我的第一个容器化应用)


## 1 Kubeadm 部署集群
1. 2017年，kubeadm诞生，源代码在 ```kubernetes/cmd/kubeadm```。其中，```app/phases``` 文件夹下的代码，对应的就是下面详细介绍的每一个具体步骤

1. 目的
    - 让用户能够通过这样两条指令完成一个 Kubernetes 集群的部署：
        ```bash

        # 创建一个Master节点
        $ kubeadm init

        # 将一个Node节点加入到当前集群中
        $ kubeadm join <Master节点的IP和端口>
        ```
1. 原理
    1. kubeadm 的工作原理
        - 使用 kubeadm 的第一步，是在机器上手动安装 kubeadm、kubelet 和 kubectl 这三个二进制文件
    1. kubeadm init 的工作流程
        1. 执行 kubeadm init 指令后，kubeadm 首先要做的，是一系列的检查工作，以确定这台机器可以用来部署 Kubernetes。这一步检查，称为“Preflight Checks”
        1. 在通过了 Preflight Checks 之后，kubeadm 要做的，是生成 Kubernetes 对外提供服务所需的各种证书和对应的目录。
            - Kubernetes 对外提供服务时，除非专门开启“不安全模式”，否则都要通过 HTTPS 才能访问 kube-apiserver。这就需要为 Kubernetes 集群配置好证书文件。
            - kubeadm 为 Kubernetes 项目生成的证书文件都放在 Master 节点的 ```/etc/kubernetes/pki``` 目录下。在这个目录下，最主要的证书文件是 ca.crt 和对应的私钥 ca.key。
        1. 证书生成后，kubeadm 接下来会为其他组件生成访问 kube-apiserver 所需的配置文件。这些文件的路径是：```/etc/kubernetes/xxx.conf```
            - 这些文件里面记录的是，当前这个 Master 节点的服务器地址、监听端口、证书目录等信息。这样，对应的客户端（比如 scheduler，kubelet 等），可以直接加载相应的文件，使用里面的信息与 kube-apiserver 建立安全连接。
        1. 接下来，kubeadm 会为 Master 组件生成 Pod 配置文件
            - Kubernetes 有三个 Master 组件 kube-apiserver、kube-controller-manager、kube-scheduler，而它们都会被使用 Pod 的方式部署起来
            - 在 Kubernetes 中，有一种特殊的容器启动方法叫做“Static Pod”。它允许你把要部署的 Pod 的 YAML 文件放在一个指定的目录里。这样，当这台机器上的 kubelet 启动时，它会自动检查这个目录，加载所有的 Pod YAML 文件，然后在这台机器上启动它们
            - **从这一点也可以看出，kubelet 在 Kubernetes 项目中的地位非常高，在设计上它就是一个完全独立的组件，而其他 Master 组件，则更像是辅助性的系统容器**
            - 在 kubeadm 中，Master 组件的 YAML 文件会被生成在 ```/etc/kubernetes/manifests``` 路径下
        1. 等待 Master 组件完全运行起来，然后，kubeadm 就会为集群生成一个 bootstrap token
            - 在后面，只要持有这个 token，任何一个安装了 kubelet 和 kubadm 的节点，都可以通过 kubeadm join 加入到这个集群当中
        1. 在 token 生成之后，kubeadm 会将 ca.crt 等 Master 节点的重要信息，通过 ConfigMap 的方式保存在 Etcd 当中，供后续部署 Node 节点使用。
            - 这个 ConfigMap 的名字是 ```cluster-info```
        1. kubeadm init 的最后一步，就是安装默认插件
            - Kubernetes 默认 kube-proxy 和 DNS 这两个插件是必须安装的。它们分别用来提供整个集群的服务发现和 DNS 功能。其实，这两个插件也只是两个 **容器镜像** 而已，所以 kubeadm 只要用 Kubernetes 客户端创建两个 Pod 就可以了
    1. kubeadm join 的工作流程
        > 为什么执行 kubeadm join 需要 bootstrap token 呢？
        - 因为，任何一台机器想要成为 Kubernetes 集群中的一个节点，就必须在集群的 kube-apiserver 上注册。可是，要想跟 apiserver 打交道，这台机器就必须要获取到相应的证书文件（CA 文件）。可是，为了能够一键安装，就不能让用户去 Master 节点上手动拷贝这些文件。
        - 所以，kubeadm 至少需要发起一次“不安全模式”的访问到 kube-apiserver，从而拿到保存在 ConfigMap 中的 cluster-info（它保存了 APIServer 的授权信息）。而 bootstrap token，扮演的就是这个过程中的安全验证的角色。
        - 只要有了 cluster-info 里的 kube-apiserver 的地址、端口、证书，kubelet 就可以以“安全模式”连接到 apiserver 上，这样一个新的节点就部署完成了
    1. 配置 kubeadm 的部署参数
        > Best Practise：```kubeadm init --config kubeadm.yaml```
        - 给 kubeadm 提供一个 YAML 文件（比如，kubeadm.yaml），它的内容如下所示（仅列举了主要部分）：
            ```yaml

            apiVersion: kubeadm.k8s.io/v1alpha2
            kind: MasterConfiguration
            kubernetesVersion: v1.11.0
            api:
                advertiseAddress: 192.168.0.102
                bindPort: 6443
                ...
            etcd:
                local:
                    dataDir: /var/lib/etcd
                    image: ""
            imageRepository: k8s.gcr.io
            kubeProxy:
                config:
                    bindAddress: 0.0.0.0
                    ...
            kubeletConfiguration:
                baseConfig:
                    address: 0.0.0.0
                    ...
            networking:
                dnsDomain: cluster.local
                podSubnet: ""
                serviceSubnet: 10.96.0.0/12
            nodeRegistration:
                criSocket: /var/run/dockershim.sock
                ...
            ```
        - 通过制定这样一个部署参数配置文件，就可以很方便地在这个文件里填写各种自定义的部署参数了。比如，现在要指定 kube-apiserver 的参数，那么我只要在这个文件里加上这样一段信息：
            ```yaml

            ...
            apiServerExtraArgs:
                advertise-address: 192.168.0.103
                anonymous-auth: false
                enable-admission-plugins: AlwaysPullImages,DefaultStorageClass
                audit-log-path: /home/johndoe/audit.log
            ```
        - 然后，kubeadm 就会使用上面这些信息替换 ```/etc/kubernetes/manifests/kube-apiserver.yaml``` 里的 ```command``` 字段里的参数了。

1. 问题
    1. Kubernetes 的功能那么多，这样一键部署出来的集群，能用于生产环境吗？
        > 不能（也许现在还是这样的）
        - 因为 kubeadm 目前最欠缺的是，一键部署一个高可用的 Kubernetes 集群，即：Etcd、Master 组件都应该是多节点集群，而不是现在这样的单点。
    1. 为什么不用容器部署 Kubernetes 呢？
        - 事实上，在 Kubernetes 早期的部署脚本里，确实有一个脚本就是用 Docker 部署 Kubernetes 项目的
        - 但是，这样做会带来一个很麻烦的问题，即：如何容器化 kubelet
        - kubelet 是 Kubernetes 项目用来操作 Docker 等容器运行时的核心组件。可是，除了跟容器运行时打交道外，kubelet 在配置容器网络、管理容器数据卷时，都需要直接操作宿主机
        > 解决方法：把 kubelet 直接运行在宿主机上，然后使用容器部署其他的 Kubernetes 组件。


## 2 从 0 到 1 搭建一个完整的 Kubernetes 集群
1. 实践流程
    1. 在所有节点上安装 Docker 和 kubeadm；
    1. 部署 Kubernetes Master；
    1. 部署容器网络插件；
    1. 部署 Kubernetes Worker；
    1. 部署 Dashboard 可视化插件；
    1. 部署容器存储插件。
1. **具体实践详见本仓库的操作，本标题下仅记录部署过程中一些操作背后的原因**
1. client 机的配置
    - 而需要这些配置命令的原因是：Kubernetes 集群默认需要加密方式访问。所以，这几条命令，就是将刚刚部署生成的 Kubernetes 集群的安全配置文件，保存到当前用户的.kube 目录下，kubectl 默认会使用这个目录下的授权信息访问 Kubernetes 集群。
        ```bash

        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
        ```
    - 如果不这么做的话，我们每次都需要通过 export KUBECONFIG 环境变量告诉 kubectl 这个安全配置文件的位置。
1. 部署网络插件
    - 网络插件会在每一个节点上都创建一个控制组件的Pod

1. 部署 Kubernetes 的 Worker 节点
    - Kubernetes 的 Worker 节点跟 Master 节点几乎是相同的，它们运行着的都是一个 kubelet 组件。唯一的区别在于，Master 在 kubeadm init 的过程中，kubelet 启动后，Master 节点上还会自动运行 kube-apiserver、kube-scheduler、kube-controller-manger 这三个系统 Pod。
    - 所以，相比之下，部署 Worker 节点反而是最简单的，只需要两步即可完成。
        1. 第一步，在所有 Worker 节点上执行“安装 kubeadm 和 Docker”一节的所有步骤。
        1. 第二步，执行部署 Master 节点时生成的 kubeadm join 指令

1. 通过 Taint/Toleration 调整 Master 执行 Pod 的策略
    - 为节点打上“污点”（Taint）的命令是：
        ```bash
        kubectl taint nodes node1 foo=bar:NoSchedule
        ```
    - Pod 声明 Toleration 的方式是在 Pod 的 .yaml 文件中的 spec 部分，加入 tolerations 字段即可：
        ```yaml

        apiVersion: v1
        kind: Pod
        ...
        spec:
            tolerations:
            - key: "foo"
                operator: "Equal"
                value: "bar"
                effect: "NoSchedule"
        ```
        这个 Toleration 的含义是，这个 Pod 能“容忍”所有键值对为 foo=bar 的 Taint（ operator: “Equal”，“等于”操作）
    - 举例：如果通过 kubectl describe 检查一下 Master 节点的 Taint 字段，就会有所发现了：
        ```bash

        $ kubectl describe node master

        Name:               master
        Roles:              master
        Taints:             node-role.kubernetes.io/master:NoSchedule
        ```
        可以看到，Master 节点默认被加上了 ```node-role.kubernetes.io/master:NoSchedule``` 这样一个“污点”，其中“键”是 ```node-role.kubernetes.io/master```，而没有提供“值”。

        此时，你就需要像下面这样用“Exists”操作符（operator: “Exists”，“存在”即可）来说明，该 Pod 能够容忍所有以 foo 为键的 Taint，才能让这个 Pod 运行在该 Master 节点上：

        ```yaml

        apiVersion: v1
        kind: Pod
        ...
        spec:
            tolerations:
            - key: "foo"
                operator: "Exists"
                effect: "NoSchedule"
        ```
    - 当然，如果就是想要一个单节点的 Kubernetes，删除这个 Taint 才是正确的选择：
        ```bash

        $ kubectl taint nodes --all node-role.kubernetes.io/master-
        ```
        如上所示，在 ```node-role.kubernetes.io/master``` 这个键后面加上了一个短横线“-”，这个格式就意味着移除所有以 ```node-role.kubernetes.io/master``` 为键的 Taint。
1. 部署 Dashboard 可视化插件
    - 需要注意的是，由于 Dashboard 是一个 Web Server，很多人经常会在自己的公有云上无意地暴露 Dashboard 的端口，从而造成安全隐患。所以，1.7 版本之后的 Dashboard 项目部署完成后，默认只能通过 Proxy 的方式在本地访问。具体的操作，可以查看 Dashboard 项目的官方文档。
    - 而如果想从集群外访问这个 Dashboard 的话，就需要用到 Ingress

1. 部署容器存储插件
    - 如果在某一台机器上启动的一个容器，显然无法看到其他机器上的容器在它们的数据卷里写入的文件。**这是容器最典型的特征之一：无状态**
    - 而容器的持久化存储，就是用来保存容器存储状态的重要手段：存储插件会在容器里挂载一个基于网络或者其他机制的远程数据卷，使得在容器里创建的文件，实际上是保存在远程存储服务器上，或者以分布式的方式保存在多个节点上，而与当前宿主机没有任何绑定关系。这样，无论你在其他哪个宿主机上启动新的容器，都可以请求挂载指定的持久化存储卷，从而访问到数据卷里保存的内容。**这就是“持久化”的含义**

**其实，在很多时候，大家说的所谓“云原生”，就是“Kubernetes 原生”的意思**


## 3 牛刀小试：我的第一个容器化应用
1. 几个概念
    1. 首先要做的，是制作容器的镜像
    1. 而有了容器镜像之后，需要按照 Kubernetes 项目的规范和要求，将镜像组织为它能够“认识”的方式，然后提交上去。
        - Kubernetes 项目能“认识”的方式是：编写 ```.yaml``` 配置文件
        ```yaml

        apiVersion: apps/v1
        kind: Deployment
        metadata:
            name: nginx-deployment
        spec:
            selector:
                matchLabels:
                    app: nginx
            replicas: 2
            template:
                metadata:
                    labels:
                        app: nginx
                spec:
                    containers:
                    - name: nginx
                        image: nginx:1.7.9
                        ports:
                        - containerPort: 80
        ```
    1. **Pod 就是 Kubernetes 世界里的“应用”；而一个应用，可以由多个容器组成**
    1. 控制器模式   
        - 需要注意的是，像这样使用一种 API 对象（Deployment）管理另一种 API 对象（Pod）的方法，在 Kubernetes 中，叫作“控制器”模式（controller pattern）
    1. Metadata：是 API 对象的“标识”，即元数据，它也是我们从 Kubernetes 里找到这个对象的主要依据。这其中最主要使用到的字段是 Labels。
        - Labels 就是一组 key-value 格式的标签。而像 Deployment 这样的控制器对象，就可以通过这个 Labels 字段从 Kubernetes 中过滤出它所关心的被控制对象
        - 而这个过滤规则的定义，是在 Deployment 的“spec.selector.matchLabels”字段。我们一般称之为：Label Selector
        - **需要注意的是，在命令行中，所有 key-value 格式的参数，都使用“=”而非“:”表示**
    1. Annotations：另外，在 Metadata 中，还有一个与 Labels 格式、层级完全相同的字段叫 Annotations，它专门用来携带 key-value 格式的内部信息。所谓内部信息，指的是对这些信息感兴趣的，是 Kubernetes 组件本身，而不是用户。所以大多数 Annotations，都是在 Kubernetes 运行过程中，被自动加在这个 API 对象上
    1. Kubernetes 的 API 对象的定义格式：大多可以分为 Metadata 和 Spec 两个部分。前者存放的是这个对象的元数据，对所有 API 对象来说，这一部分的字段和格式基本上是一样的；而后者存放的，则是属于这个对象独有的定义，用来描述它所要表达的功能
1. 使用 kubectl describe 命令，查看一个 API 对象的细节
    - 有一个部分值得特别关注，它就是 Events（事件）
        - 在 Kubernetes 执行的过程中，对 API 对象的所有重要操作，都会被记录在这个对象的 Events 里，并且显示在 kubectl describe 指令返回的结果中。
        - 所以，这个部分正是我们将来进行 Debug 的重要依据。如果有异常发生，你一定要第一时间查看这些 Events，往往可以看到非常详细的错误信息。
1. emptyDir 类型
    - 它其实就等同于我们之前讲过的 Docker 的隐式 Volume 参数，即：不显式声明宿主机目录的 Volume。所以，Kubernetes 也会在宿主机上创建一个临时目录，这个目录将来就会被绑定挂载到容器所声明的 Volume 目录上。
    - 备注：不难看到，Kubernetes 的 emptyDir 类型，只是把 Kubernetes 创建的临时目录作为 Volume 的宿主机目录，交给了 Docker。这么做的原因，是 Kubernetes 不想依赖 Docker 自己创建的那个 _data 目录。
1. 命令
    ```bash
    
    kubectl create -f <xxx.yaml>

    kubectl replace -f <xxx.yaml>

    kubectl apply -f <xxx.yaml>

    kubectl delete -f <xxx.yaml>

    kubectl get pods -l <key=value>

    kubectl describe pod <pod name>

    kubectl exec -it <pod name> -- /bin/bash
    ```


![03 Container Layout and Kubernetes Job Management](./03%20Container%20Layout%20and%20Kubernetes%20Job%20Management.md)