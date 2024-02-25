#!/bin/bash
apt-get update
apt-get install vim
#install and config haproxy
apt-get install haproxy

mkdir /etc/haproxy/haproxy.cfg
cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
        defaults
          mode http
          timeout client 10s
          timeout connect 5s
          timeout server 10s 
          timeout http-request 10s
        frontend kube_apiserver_frontend
          bind *:6443
          mode tcp
          default_backend kube_apiserver_backend

        backend kube_apiserver_backend
          option httpchk GET /healthz
          http-check expect status 200
          mode tcp
          option ssl-hello-chk
          balance roundrobin
            server k8s-master-1 172.16.1.11:6443 check fall 3 rise 2
            server k8s-master-2 172.16.1.12:6443 check fall 3 rise 2

        frontend http_frontend
          bind *:80
          mode tcp
          default_backend http_backend

        backend http_backend
          mode tcp
          balance roundrobin
            server k8s-worker-1 172.16.2.11:30100 check send-proxy-v2
            server k8s-worker-2 172.16.2.12:30100 check send-proxy-v2

        frontend https_frontend
          bind *:443
          mode tcp
          default_backend https_backend

        backend https_backend
          mode tcp
          balance roundrobin
            server k8s-worker-1 172.16.2.11:30101 check send-proxy-v2
            server k8s-worker-2 172.16.2.12:30101 check send-proxy-v2

EOF

systemctl restart haproxy

#install and config keepalived
apt-get install keepalived
mkdir /etc/keepalived/keepalived.conf
cat <<EOF | sudo tee /etc/keepalived/keepalived.conf
          vrrp_script check_apiserver {
            script "killall -0 haproxy"
            interval 3
            timeout 10
          }

          vrrp_instance VI_1 {
              state MASTER
              interface eth1
              virtual_router_id 201
              priority 200
              advert_int 1
              authentication {
                  auth_type PASS
                  auth_pass secret
              }
              virtual_ipaddress {
                  {{ cluster_vip }}/24
              }
              track_script {
                  check_apiserver
              }
          }
EOF
systemctl restart keepalived

