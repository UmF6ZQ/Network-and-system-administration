vagrant up
wsl ansible-playbook -i playbook/lb_inventory.yml playbook/lb.yml --extra-vars "cluster_vip=172.16.0.16"
wsl ansible-playbook -i playbook/cluster_inventory.yml playbook/cluster_playbook.yml --extra-vars "cluster_vip=172.16.0.16"