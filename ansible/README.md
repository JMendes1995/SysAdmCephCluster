# ansible infra configuration
## enter into ansible folder
```bash
cd SysAdmCephCluster/ansible
```

## build gcp inventory
```bash
Initial command 

ansible-playbook -i inventory/ playbooks/init/*  --extra-vars "service_account_file=~/sysadmcephcluster-7893cafdba84.json  bucket_name=sysadm_cepth_cluster_tfstate project_name=SysAdmCephCluster project_id=sysadmcephcluster region=europe-west4 path_local_public_key=../../ssh_keys/idrsa.pub command=apply" --tags "apply, init"  -vvv

arguments:
service_account_file: location of service account file in json format got from GCP iam page.
bucket_name: will store all terraform states
project_name: name of the project
porject_id: id of the project
region: region name where the resources will be deployed
path_local_public_key: location of bastion ssh pub key
tags: single of multiple value field (options: init, apply, destroy) 
    if init is selected will create the ansible inventory, tfvars file and bastion ssh key pair
    if apply is selected will create the tfstate bucket
    if destroy is selected will destroy the tfstate bucket

```

## setup bastion initial configurations  
```bash
ansible-playbook -i inventory/  playbooks/bastion/setup.yaml -v
```

## setup base infrastructure initial configurations  
```bash
ansible-playbook -i inventory/  playbooks/base.yaml  -e command=(apply or destroy) -v
```
