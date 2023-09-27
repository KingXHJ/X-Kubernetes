## Kubernetes Audit Mechanism
Kubernetes 为了加强对集群操作的安全监管，从 1.4 版本开始引入审计机制，主要体现为审计日志（Audit Log）。审计日志按照时间顺序记录了与安全相关的各种事件，这些事件有助于系统管理员快速、集中了解发生了什么事情、作用于什么对象、在什么时间发生、谁（从哪儿）触发的、在哪儿观察到的、活动的后续处理行为是怎样的，等等

API Server 把客户端的请求（Request）的处理流程视为一个"链条"，这个链条上的每个"节点"就是一个状态（Stage），从开始到结束的所有 Request Stage 如下：
- RequestReceived：在 Audit Handler 收到请求后生成的状态
- ResponseStarted：响应 Header 已经发送但 Body 还没有发送的状态，仅对长期运行的请求（Long-running Requests）有效，例如 Watch
- ResponseComplete：Body 已经发送完成
- Panic：严重错误（Panic）发生时的状态


我们可以将 Audit Policy 视作一组规则，这组规则定义了有哪些事件及数据需要记录（审计）。当一个事件被处理时，规则列表会依次尝试匹配该事件，第 1 个匹配的规则会决定审计日志的级别（Audit Level），目前定义的几种级别如下（按级别从低到高排列）：
- None：不生成审计日志
- Metadata：只记录 Request 请求的元数据如 requesting user、timestamp、resource、verb 等，但不记录请求及响应的具体内容
- Request：记录 Request 请求的元数据及请求的具体内容
- RequestResponse：记录事件的元数据，以及请求与应答的具体内容

None 以上的级别会生成相应的审计日志并将审计日志输出到后端，当前的后端实现如下：
1. Log backend：以本地日志文件记录保存，为 JSON 日志格式
1. Webhook backend：回调外部接口进行通知，审计日志以 JSON 格式发送（POST 方式）给 Webhook Server，支持 batch 和 blocking 这两种通知模式
1. Batching Dynamic backend：一种动态配置的 Webhook backend，是通过 AuditSink API 动态配置的，在 Kubernetes 1.13 版本中引入

需要注意的是，开启审计功能会增加 API Server 的内存消耗量，因为此时需要额外的内存来存储每个请求的审计上下文数据，而增加的内存量与审计功能的配置有关，比如更详细的审计日志所需的内存更多

对于审计日志的采集和存储，一种常见做法是，将审计日志以本地日志文件方式保存，然后使用日志采集工具（例如 Fluentd）采集该日志并存储到 Elasticsearch 中，用 Kibana 等 UI 界面对其进行展示和查询。另一种常见做法是用 Logstash 采集 Webhook 后端的审计事件，通过 Logstash 将来自不同用户的事件保存为文件或者将数据发送到后端存储（例如
Elasticsearch）