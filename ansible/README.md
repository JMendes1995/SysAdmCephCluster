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
ansible-playbook -i inventory/  playbooks/bastion/* --key-file "../ssh_keys/idrsa" --tags setup,proxy_jump --ask-become-pass -vvv
```

## setup bastion initial configurations  
```bash
ansible-playbook -i inventory/  playbooks/bastion/setup.yaml  --key-file "../ssh_keys/idrsa" -vvv
```

## setup proxy jump locally
```bash
ansible-playbook -i inventory/  playbooks/bastion/proxy_jump.yaml  --tags "proxy_jump" --ask-become-pass -vvv
```

## ceph cluster 
```bash
automated run
ansible-playbook -i inventory/  playbooks/cephCluster/ceph_cluster.yaml  -l bastion --key-file "../ssh_keys/idrsa" --tags ceph_node,ceph_admin,ceph_monitor,ceph_manager  -vvv

single run
ansible-playbook -i inventory/  playbooks/cephCluster/setup_node.yaml  -l bastion --key-file "../ssh_keys/idrsa" --tags ceph_node,ceph_admin,ceph_monitor,ceph_manage"  -v
```

ansible-playbook -i inventory/  playbooks/cephCluster/ceph_cluster.yaml  -l osd_node --key-file "../ssh_keys/idrsa" --tags ceph_node,ceph_admin,ceph_osd,ceph_monitor,ceph_manager -v

##### latest changes

ansible-playbook -i inventory/  playbooks/cephCluster/ceph_cluster.yaml  --key-file "../ssh_keys/idrsa" --tags ceph_init -v

### client












###########################################
execution order

---------> generate ssh keys for bastion user
ansible-playbook -i inventory build_project/generate_ssh_keys.yaml --tags ssh_keys -vv

---------> create tf state bucket build tfvars and build inventory
ansible-playbook -i inventory build_project/main.yaml  --extra-vars "command=(apply or destroy)"  -vv

---------> terraform base 
./executor.sh base apply


---------> generate ssh proxy locally
ansible-playbook -i inventory bastion/build_local_proxy.yaml --tags proxy_jump --ask-become-pass  -vv

---------> initial setup bastion 
ansible-playbook -i inventory common/init.yaml -l bastion --tags ceph_init --key-file "../ssh_keys/idrsa"  -vv


---------> initial setup all nodes 
./executor.sh cephManager apply
./executor.sh cephrbd apply
./executor.sh cephObjectStorageDevice apply

ansible-playbook -i inventory common/init.yaml -l all --tags ceph_init,ceph_node,ceph_client --key-file "../ssh_keys/idrsa"  -vv

---------> setup ceph manager and monitor
ansible-playbook -i inventory cephCluster/cephManager.yaml -l manager --tags ceph_manager,ceph_monitor --key-file "../ssh_keys/idrsa"  -vv

setup ceph osd
ansible-playbook -i inventory cephCluster/cephOSD.yaml -l osd --tags ceph_osd --key-file "../ssh_keys/idrsa"  -vv

setup ceph rbd
ansible-playbook -i inventory cephCluster/cephrbd.yaml -l rbd --tags ceph_rbd --key-file "../ssh_keys/idrsa"  -vv
###########################################


test cluster    