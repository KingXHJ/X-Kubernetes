## Kubernetes API Extension
随着 Kubernetes 的发展，用户对 Kubernetes 的扩展性也提出了越来越高的要求。从 1.7 版本开始，Kubernetes 引入扩展 API 资源的能力，使得开发人员在不修改 Kubenetes 核心代码的前提下可以对 Kubernetes API 进行扩展，并仍然使用 Kubernetes 的语法对新增的 API 进行操作，这非常适用于在 Kubernetes 上通过其 API 实现其他功能（例如第三方性能指标采集服务）或者测试实验性新特性（例如外部设备驱动）

在 Kubernetes 中，所有对象都被抽象定义为某种资源对象，同时系统会为其设置一个 API URL 入口（API Endpoint），对资源对象的操作（如新增、删除、修改、查看等）都需要通过 Master 的核心组件 API Server 调用资源对象的 API 来完成。与 API Server 的交互可以通过 kubectl 命令行工具或访问其 RESTful API 进行。每个 API 都可以设置多个版本，在不同的 API URL 路径下区分，例如 "/api/vl" 或 "/apis/extensions/v1beta1" 等。使用这种机制后，用户可以很方便地定义这些 API 资源对象（YAML 配置），并将其提交给Kubernetes （调用 RESTful API），来完成对容器应用的各种管理工作

Kubernetes 系统内置的 Pod、RC、Service、ConfigMap、Volume 等资源对象已经能够满足常见的容器应用管理要求，但如果用户希望将其自行开发的第三方系统纳入 Kubernetes，并使用 Kubernetes 的 API 对其自定义的功能或配置进行管理，就需要对 API 进行扩展了。目前 Kubernetes 提供了以下两种 API 扩展机制供用户扩展 API：
1. CRD：复用 Kubernetes 的 API Server，无须编写额外的 API Server。用户只需要定义 CRD，并且提供一个 CRD 控制器，就能通过 Kubernetes 的 API 管理自定义资源对象了，同时要求用户的 CRD 对象符合 API Server 的管理规范
1. API 聚合：用户需要编写额外的 API Server，可以对资源进行更细粒度的控制（例如，如何在各 API 版本之间切换），要求用户自行处理对多个 API 版本的支持

### 使用 CRD扩展 API 资源
CRD Kubernetes 从 1.7 版本开始引入的特性，在 Kubernetes 早期版本中被称为 TPR（ThirdPartyResource，第三方资源）。TPR 从 Kubernetes 1.8 版本开始停用，被 CRD 全面替换

CRD 本身只是一段声明，用于定义用户自定义的资源对象。但仅有 CRD 的定义并没有实际作用，用户还需要提供管理 CRD 对象的 CRD 控制器 (CRD Controller) ，才能实现对 CRD 对象的管理。CRD 控制器通常可以通过 Go 语言进行开发，需要遵循 Kubernetes 的控制器开发规范，基于客户端库 client-go 实现 Informer、ResourceEventHandler、Workqueue 等组件具体的功能处理逻辑，详细的开发过程请参考官方示例和 client-go 库的说明

1. 创建CRD的定义
    - CRD 定义中的关键字段如下：
        1. group：设置 API 所属的组，将其映射为 API URL 中 /apis/ 的下一级目录，设置 networking.istio.io 生成的 API URL 路径为 /apis/networking.istio.io
        1. scope：该 API 的生效范围，可选项为 Namespaced（由 Namespace 限定）和 Cluster（在集群范围全局生效，不局限于任何命名空间），默认值为 Namespaced
        1. versions：设置此 CRD 支持的版本，可以设置多个版本，用列表形式表示。目前还可以设置名为 Version 字段，只能设置一个版本，在将来的 Kubernetes 版本中会被弃用，建议使用 versions 进行设置。如果该 CRD 支待多个版本，则每个版本都会在 API URL "/apis/networking.istio.io"的下一级进行体现，例如 /apis/networking.istio.io/v1 或 /apis/networking.istio.io/vlalpha3等。每个版本都可以设置下列参数：
            - name：版本的名称，例如 v1、v1alpha3 等
            - served：是否启用，设置为 true 表示启用
            - storage：是否进行存储，只能有一个版本被设置为 true
        1. names：CRD 的名称，包括单数、复数、kind、所属组等名称的定义，可以设置如下参数：
            - kind：CRD 的资源类型名称，要求以驼峰式命名规范进行命名（单词的首字母都大写），例如 VirtualService
            - listKind：CRD 列表，默认设置为<kind>List 格式，例如 VirtualServiceList
            - singular：单数形式的名称，要求全部小写，例如 virtualservice
            - plural：复数形式的名称，要求全部小写，例如 virtualservices
            - shortNames：缩写形式的名称，要求全部小写，例如 vs
            - categories：CRD 所属的资源组列表。例如，VirtualService 属于  istio-io 组和 networking-istio-io 组，用户通过查询 istio-io 组和  networking-istio-io 组，也可以查询到该 CRD 实例
1. 基于CRD的定义创建自定义资源对象
1. CRD的高级特性
    1. CRD的subresource子资源
    1. CRD的校验（Validation）机制
    1. 自定义查看CRD时需要显示的列
    1. Finalizer（CRD资源对象的预删除钩子方法）
    1. CRD的多版本（Versioning）特性
    1. 结构化的CRD对象
1. 小结
    - CRD 极大扩展了 Kubernetes 的能力，使用户像操作 Pod 一样操作自定义的各种资源对象。CRD 已经在一些基于 Kubernetes 的第三方开源项目中得到广泛应用，包括 CSI 存储插件、Device Plugin（GPU 驱动程序）、Istio（Service Mesh 管理）等，已经逐渐成为扩展 Kubenetes 能力的标准


### 使用API聚合机制扩展API资源
1. 在Master的API Server中启用API聚合功能
1. 注册自定义API Server资源
1. 实现和部署自定义API Server

