#!/bin/bash
echo "~~> 使用镜像源"
curl -L "http://mirrors.aliyun.com/repo/Centos-7.repo" -o /etc/yum.repos.d/CentOS-Base.repo
echo "~~> 安装相关工具"
yum install -y yum-utils curl vim 

echo "~~> 使能ntp,并时间同步"
yum install -y ntp ntpdate
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai 
/usr/sbin/ntpdate ntp1.aliyun.com
systemctl start ntpd
systemctl enable ntpd

echo '~~> 设置nameserver'
echo "nameserver 8.8.8.8">/etc/resolv.conf
cat /etc/resolv.conf

echo "~~> 安装docker"
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<-EOF 
{
  "registry-mirrors": [
      "https://8s2vzrff.mirror.aliyuncs.com",
      "https://docker.mirrors.ustc.edu.cn",
      "https://registry.docker-cn.com"
  ]
}
EOF

echo "~~>> 将用户加入docker组"
groupadd -f docker
gpasswd -a vagrant docker # usermod -aG docker vagrant # ${USER}
newgrp docker  

echo "~~>> 启动docker服务"
systemctl enable docker
systemctl start docker
docker version

echo "~~> 安装kubectl"
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null
kubectl version --client

echo "~~> 安装k8s前置条件"
yum install -y conntrack-tools socat ebtables ipset
echo "~~>> 关闭 selinux"
getenforce 
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
echo "~~>> 关闭防火墙"
systemctl status firewalld
systemctl disable firewalld
systemctl stop firewalld
echo "~~>> 禁止swap"
swapoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab
echo "~~>> 网络"
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 > /proc/sys/net/ipv4/ip_forward
echo '~~> 使能iptable kernel参数'
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward=1
EOF
sysctl -p