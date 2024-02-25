# Reset cluster
kubeadm reset -f
rm -rf ~/.kube
rm -rf /etc/kubernetes/manifests  
rm -rf /var/lib/etcd

#John worker
[john_command]

echo 'Environment="KUBELET_EXTRA_ARGS=--node-ip=[]"' >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet