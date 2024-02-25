kubectl apply -f https://raw.githubusercontent.com/ku.kube/c"bernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/baremetal/deploy.yaml
kubectl -n ingress-nginx patch svc ingress-nginx-controller --patch '{\"spec\": { \"type\": \"NodePort\", \"ports\": [ { \"port\": 80, \"nodePort\": 30100 }, { \"port\": 443, \"nodePort\": 30101 } ] } }'
kubectl -n ingress-nginx patch configmap ingress-nginx-controller --patch-file patch-configmap.yaml
kubectl apply -f my-nginx-deploy.yaml
kubectl apply -f my-nginx-svc.yaml