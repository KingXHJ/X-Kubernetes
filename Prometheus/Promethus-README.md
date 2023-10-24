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

1. 设置Ingress规则

```bash

$ kubectl apply -f 01-prometheus-ingress-nginx-termination-at-ingress-controller.yaml
```
