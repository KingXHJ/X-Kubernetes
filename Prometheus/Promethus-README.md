# Setup Prometheus

## 目录
- [Install Prometheus Operator](#install-prometheus-operator)
- [Set Ingress for Prometheus-Grafana & Prometheus-UI](#set-ingress-for-prometheus-grafana--prometheus-ui)


## Install Prometheus Operator
- [Install Prometheus Operator](./script/01-prometheus-helm-install.sh)

```

default user name: admin
default user password: prom-operator
```


## Set Ingress for Prometheus-Grafana & Prometheus-UI
1. Let mkcert create tls certification files

参考[文件](../mkcert/mkcert-README.md)

1. 设置[Ingress规则](./yaml/01-prometheus-ingress-nginx-termination-at-ingress-controller.yaml)

**非常有趣的是，prometheus不能使用```spec.rules.http.paths.backend.service.port.name=http```，只能用```spec.rules.http.paths.backend.service.port.number=80```**

```bash

$ kubectl apply -f 01-prometheus-ingress-nginx-termination-at-ingress-controller.yaml
```


## Q&A
1. 发现```Prometheus UI```界面中，```Status```下拉菜单中，```Targets```选项里，会出现例如```serviceMonitor/prometheus-operator/prometheus-operator-kube-p-kube-controller-manager/0 (0/1 up)```的问题

    解决方案：

    1. 针对 ```kube-controller-manager, kube-scheduler``` ，修改```/etc/kubernetes/manifests/```路径下对应的```yaml```文件中的```--bind-address=127.0.0.1```为```--bind-address=0.0.0.0```
    1. 针对```etcd```，修改```/etc/kubernetes/manifests/```路径下对应的```yaml```文件中的```--listen-metrics-urls=http://127.0.0.1:2381```为```--listen-metrics-urls=http://0.0.0.0:2381```
        - 不可以把```0.0.0.0```换成```master-node IP，eg. 10.10.1.194```，否则会报错```Startup probe failed: Get "http://127.0.0.1:2381/health": dial tcp 127.0.0.1:2381: connect: connection refused```
    1. 针对```kube-proxy```
        - **失败！！！通过```netstat -tuln```命令发现，node仍然在监听```127.0.0.1:10249```** 
            通过命令```kubectl edit ds kube-proxy -n kube-system```修改```yaml```文件如下：

            ```yaml
            spec:
            containers:
            - command:
                - /usr/local/bin/kube-proxy
                - --config=/var/lib/kube-proxy/config.conf
                - --hostname-override=$(NODE_NAME)
                - --metrics-bind-address=0.0.0.0:10249
            ```

        - **成功！！！[官方文档](https://v1-24.docs.kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-proxy/)中说：“如果配置文件由 --config 指定，则忽略此参数(--metrics-bind-address ipport )”** 
            1. 参考[网站](https://www.coder.work/article/7593697)使用命令```kubectl edit cm/kube-proxy -n kube-system```去编辑配置文件
            1. 将```metricsBindAddress: ""```变成```metricsBindAddress: 0.0.0.0:10249```
            1. **注意，必须马上执行```kubectl rollout restart ds kube-proxy -n kube-system```，否则它们将无法获得配置。** 
            1. 通过命令```kubectl rollout status ds kube-proxy -n kube-system```检查状态
    