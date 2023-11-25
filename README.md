# SysAdmCephCluster

![image info](./resources/network_diagram.png)


## How to setup the environment 

## enter into ansible folder
```bash
cd SysAdmCephCluster/ansible
```

### Generate bastion ssh keys 
```bash
ansible-playbook -i inventory build_project/generate_ssh_keys.yaml --tags ssh_keys -vv
```
### create tf state bucket, build tfvars and build inventory
```bash
ansible-playbook -i inventory build_project/main.yaml  --extra-vars "command=apply"  -vv
```

### execute terraform to setup the whole infrastructure infrastructure
## enter into terraform folder
```bash
cd SysAdmCephCluster/terraform
```
```bash
./executor.sh base apply
./executor.sh cephCluster apply
```

### generate ssh proxy locally
```bash
ansible-playbook -i inventory bastion/build_local_proxy.yaml --tags proxy_jump --ask-become-pass  -vv
```
### execute common configurations amoung all hosts
#### command to apply in every node.
```bash
ansible-playbook -i inventory common/init.yaml -l all --tags ceph_init --key-file "../ssh_keys/idrsa"  -vv
```
#### command to apply seperatly
```bash
ansible-playbook -i inventory common/init.yaml -l bastion --tags ceph_init --key-file "../ssh_keys/idrsa"  -vv
```

### configure ceph monitor node
```bash
ansible-playbook -i inventory cephCluster/cephMonitor.yaml -l monitor --tags ceph_monitor_admin,ceph_monitor,ceph_osd,ceph_rbd,ceph_manager   --key-file "../ssh_keys/idrsa"  -vv
```

### configure ceph manager nodes
```bash
ansible-playbook -i inventory cephCluster/cephManager.yaml -l manager --tags ceph_manager,ceph_manager_dashboard --key-file "../ssh_keys/idrsa"  -vv
```

### configure osd node
```bash
setup ceph osd
ansible-playbook -i inventory cephCluster/cephOSD.yaml -l osd --tags ceph_osd --key-file "../ssh_keys/idrsa"  -vv
```
### configure rbd node
```bash
setup ceph rbd
ansible-playbook -i inventory cephCluster/cephrbd.yaml -l rbd --tags ceph_rbd --key-file "../ssh_keys/idrsa"  -vv
```

### usefull commands
```bash
ceph -s
ceph osd tree
ceph df 
ceph osd df 
```


### enable dashboard with proxyjump

ssh -i ssh_keys/idrsa -L 127.0.0.1:8443:(ceph_manager_private_address):8443 bastion@(bastion_public_address)



## Destroy cluster

```bash
cd SysAdmCephCluster/terraform
```
```bash
./executor.sh cephCluster destroy
./executor.sh base destroy
```

## Destroy tf state bucket

```bash
cd SysAdmCephCluster/terraform
```
```bash
ansible-playbook -i inventory build_project/main.yaml  --extra-vars "command=destroy"  -vv
```
