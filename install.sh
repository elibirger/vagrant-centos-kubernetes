#!/bin/sh

TOKEN=$4
echo 'INSTALL KUBERNETES'
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
setenforce 0
swapoff -a
sudo systemctl stop firewalld
sudo systemctl disable firewalld
yum install -y docker kubelet kubeadm kubectl wget ntp
systemctl start ntpd
systemctl enable ntpd
#wget http://stedolan.github.io/jq/download/linux64/jq
#chmod +x ./jq
#cp jq /usr/bin
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet
if [ "$1" == "-master" ]; then
	kubeadm init --apiserver-advertise-address $2 --token=$TOKEN
  #kubectl -n kube-system get ds -l 'component=kube-proxy' -o json \
  #| jq '.items[0].spec.template.spec.containers[0].command |= .+ ["--proxy-mode=userspace"]' \
  #|   kubectl apply -f - && kubectl -n kube-system delete pods -l 'component=kube-proxy'
  #cp /etc/kubernetes/admin.conf /shared
elif [ "$1" == "-node" ]; then
	echo "I AM A NODE"
  #rm -Rf /etc/kubernetes/*
  kubeadm join $2:6443 --token=$TOKEN
  #if [ "$3" == "-last" ]; then
  #  kubectl --kubeconfig /shared/admin.conf apply -f https://git.io/weave-kube
  #  kubectl --kubeconfig /shared/admin.conf create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
  #fi
fi
echo "Wait 10.00s" && sleep 10
