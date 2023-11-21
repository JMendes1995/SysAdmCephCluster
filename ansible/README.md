# ansible infra configuration
## enter into ansible folder
```bash
cd SysAdmCephCluster/ansible
```

## build gcp inventory
```bash
Initial command 

ansible-playbook -i inventory/ playbooks/init/*  --extra-vars "service_account_file=~/sysadmcephcluster-7893cafdba84.json  bucket_name=sysadm_cepth_cluster_tfstate project_name=SysAdmCephCluster project_id=sysadmcephcluster region=europe-west4 path_local_public_key=../../ssh_keys/idrsa.pub" --tags apply,init  -vvv

ansible-playbook -i inventory/ playbooks/init/*  --extra-vars "service_account_file=~/sysadmcephcluster-7893cafdba84.json  bucket_name=sysadm_cepth_cluster_tfstate project_name=SysAdmCephCluster project_id=sysadmcephcluster region=europe-west4 path_local_public_key=../../ssh_keys/idrsa.pub"  --tags destroy  -vvv

arguments:
service_account_file: location of service account file in json format got from GCP iam page.
bucket_name: will store all terraform states
project_name: name of the project
porject_id: id of the project
region: region name where the resources will be deployed
path_local_public_key: location of bastion ssh pub key
tags: single of multiple value field (options: init, apply, destroy, ssh_keys) 
    * init ->_create the ansible inventory, tfvars file and bastion ssh key pair
    * apply -> create the tfstate bucket
    * destroy -> destroy the tfstate bucket
    * ssh_keys -> create bastion ssh keys
```

# Bastion Configuration in command
## setup bastion initial configurations and proxy jump locally
```bash
ansible-playbook -i inventory/  playbooks/bastion/* --key-file "../ssh_keys/idrsa" --tags setup,proxy_jump -vvv
```

## setup bastion initial configurations  
```bash
ansible-playbook -i inventory/  playbooks/bastion/setup.yaml  --key-file "../ssh_keys/idrsa" -vvv
```

## setup proxy jump locally
```bash
ansible-playbook -i inventory/  playbooks/bastion/proxy_jump.yaml  --tags "proxy_jump" -vvv
```

## ceph cluster 
```bash
automated run
ansible-playbook -i inventory/  playbooks/cephCluster/ceph_cluster.yaml  -l bastion --key-file "../ssh_keys/idrsa" --tags ceph_node,ceph_admin,ceph_monitor,ceph_manager  -vvv

single run
ansible-playbook -i inventory/  playbooks/cephCluster/setup_node.yaml  -l bastion --key-file "../ssh_keys/idrsa" --tags ceph_node,ceph_admin,ceph_monitor,ceph_manage"  -v
```









## setup base infrastructure initial configurations  
```bash
ansible-playbook -i inventory/  playbooks/base.yaml  -e command=(apply or destroy) -v
```
