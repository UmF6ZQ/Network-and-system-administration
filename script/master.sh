# Reset cluster
kubeadm reset -f
rm -rf ~/.kube
rm -rf /etc/kubernetes/manifests  
rm -rf /var/lib/etcd

# Init cluster
kubeadm init --control-plane-endpoint=172.16.0.16:6443 --upload-certs --apiserver-advertise-address=172.16.1.11 --pod-network-cidr=10.244.0.0/16
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubeadm token create --print-join-command #john_command

# Copy cert keys for joining
kubeadm init phase upload-certs --upload-certs  #cert


# Join another master
[john_command] --control-plane --certificate-key [cert] --apiserver-advertise-address=[ip]

# Chỉnh advertise address cho kubelet
echo 'Environment="KUBELET_EXTRA_ARGS=--node-ip=[ip]"' > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload 
systemctl restart kubelet
