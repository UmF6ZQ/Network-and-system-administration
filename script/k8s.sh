#!/bin/bash
apt-get update
swapoff -a
sed -i '/swap/d' /etc/fstab
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
        br_netfilter
EOF
#config ip tables
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
        net.bridge.bridge-nf-call-ip6tables = 1
        net.bridge.bridge-nf-call-iptables = 1
EOF

# Add Docker's official GPG key:
apt-get install ca-certificates gnupg apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

#install docker engine
apt-get install docker-ce docker-ce-cli containerd.io

#config docker deamon
mkdir /etc/docker/daemon.json
cat <<EOF | sudo tee /etc/docker/daemon.json
        {
          "exec-opts": ["native.cgroupdriver=systemd"],
          "log-driver": "json-file",
          "log-opts": {
            "max-size": "100m"
          },
          "storage-driver": "overlay2"
        }
EOF

systemctl restart docker

usermod -aG docker $(whoami)

#install kubelet, kubeadm, kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get install -y kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00
apt-mark hold kubelet kubeadm kubectl
systemctl start kubelet
