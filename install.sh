#传递的变量
the_user=$1
the_group=$2

# k8s变量
k8s_version=v1.23.5
pod_network_cidr="10.244.0.0/16"

# 变量
node1="k8s-node1"
node2="k8s-node2"
node3="k8s-node3"
# node1_ip=192.168.56.101 
# node2_ip=192.168.56.102
# node3_ip=192.168.56.103
node1_ip=172.16.5.201 
node2_ip=172.16.5.202
node3_ip=172.16.5.203

echo "~~> 修改三台主机hosts"
cat >> /etc/hosts <<EOF
${node1_ip}   ${node1}
${node2_ip}   ${node2}
${node3_ip}   ${node3}
EOF

echo "~~> 添加kube组件仓库源"
cat > /etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

echo "~~>> 安装kube组件"
yum makecache -y fast
yum install -y kubectl kubelet kubeadm --disableexcludes=kubernetes

echo "~~>> kubectl"
kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null
 kubectl version --client

echo "~~> 启动kubelet 现在每隔几秒就会重启,因为它陷入了一个等待kubeadm指令的死循环"
systemctl enable --now kubelet
systemctl start kubelet

if [[ $(hostname) == ${node1} ]]
then
    echo "~~> 主节点安装k8s"
    kubeadm init --apiserver-advertise-address=${node1_ip} \
     --image-repository registry.aliyuncs.com/google_containers \
     --kubernetes-version ${k8s_version} \
     --pod-network-cidr=${pod_network_cidr} \
     > /vagrant/kubeadm.out
    mkdir -p /home/${the_user}/.kube
    cp -i /etc/kubernetes/admin.conf /home/${the_user}/.kube/config
    chown ${the_user}:${the_group} /home/${the_user}/.kube/config
fi
