# kubernetes-vagrant-cluster

## 启用虚拟机

当虚拟机启动后,集群还处于待激活状态,各节点还未加入到集群,需求一些简单的配置

```shell
vagrant up 
```

## 安装网络插件flannel

由于 `flannel` 的镜像拉取失败,请先提前下载并载入. 然后修改 `addon/flannel/flannel.yml`的镜像.
目前使用以下两个:

- `rancher/mirrored-flannelcni-flannel:v0.17.0`
- `rancher/mirrored-flannelcni-flannel-cni-plugin:v1.0.1`

```shell
cd /vagrant
kubectl apply -f addon/flannel/flannel.yml
```

## 将其它节点加入到集群

查看 `kubeadm.out` 有加入节点的指令

```shell
kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
```

## 控制平面节点隔离

```shell
kubectl taint nodes --all node-role.kubernetes.io/master
```

## 配置 ipvs

```shell
kubectl edit configmap -n kube-system kube-proxy
```

修改其中的

```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

重启pod

```shell
kubectl get pod -n kube-system |grep kube-proxy |awk '{system("kubectl delete pod "$1" -n kube-system")}'
```

## 安装 metallb

```shell
kubectl apply -f addon/metallb/namespace.yml
helm install metallb  metallb/metallb -f addon/metallb/values.yml  -n metallb-system
```

## 安装 ingress-nginx

```shell
kubectl apply -f addon/ingress-nginx/namespace.yml
helm install  ingress-nginx ingress-nginx/ingress-nginx -f addon/ingress-nginx/values.yaml -n ingress-nginx
```

## References

- [vagrant](https://www.vagrantup.com/docs/)
- [kubeadm](https://kubernetes.io/zh/docs/setup/production-environment/tools/)