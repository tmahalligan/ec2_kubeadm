#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/


### install k8s and docker
sudo apt-get remove -y docker.io kubelet kubeadm kubectl kubernetes-cni
sudo apt-get autoremove -y
sudo apt-get install -y etcd-client vim build-essential

sudo systemctl daemon-reload

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

KUBE_VERSION=1.19.3
sudo apt-get update
sudo apt-get install -y containerd docker.io kubelet=${KUBE_VERSION}-00 kubeadm=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00 kubernetes-cni=0.8.7-00

cat <<EOF | sudo tee /etc/docker/daemon.json 
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF
sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

# start docker on reboot
sudo systemctl enable docker
sudo systemctl enable kubelet --now


### init k8s
sudo kubeadm reset -f
sudo systemctl daemon-reload
sudo service kubelet start

sudo kubeadm join --token ${token} --discovery-token-unsafe-skip-ca-verification 10.152.2.50:6443

