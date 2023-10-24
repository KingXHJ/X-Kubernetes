# Setup Prometheus

## 目录
- [Install Prometheus Operator](#install-prometheus-operator)


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
