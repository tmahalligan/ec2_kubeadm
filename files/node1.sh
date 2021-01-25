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
YOURPUBLICEC2IP=$( curl https://ipinfo.io/ip )
sudo rm /root/.kube/config
sudo kubeadm reset -f
sudo kubeadm init --kubernetes-version=${KUBE_VERSION} --ignore-preflight-errors=NumCPU --token ${token} --skip-token-print --apiserver-cert-extra-sans=$YOURPUBLICEC2IP

mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube/


### setup terminal
sudo apt-get install -y bash-completion binutils
echo 'source <(kubectl completion bash)' | sudo -u ubuntu tee >> /home/ubuntu/.bashrc
echo 'alias k=kubectl' | sudo -u ubuntu tee >> /home/ubuntu/.bashrc
echo 'alias c=clear' | sudo -u ubuntu tee >> /home/ubuntu/.bashrc
echo 'complete -F __start_kubectl k' | sudo -u ubuntu tee >> /home/ubuntu/.bashrc

sudo -u ubuntu kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
