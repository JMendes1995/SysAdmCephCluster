# SysAdmCephCluster
## Architecture diagram
![image info](./resources/network_diagram.png)

### Architecture decisions


## How to setup the environment 
### prerequisites
* google cloud cli installed
* ansible installed
* execute `ansible-galaxy collection install google.cloud` for ansible access gcp api
* terraform installed `version >=v1.6.1`
* authenticate with Google cloud cli `gcloud auth application-default login`
* Identity and Access Management (IAM) API enabled
* Compute Engine enabled (action made through GCP UI)
* install google auth library `pip install requests google-auth`
* install python requests library


### Enter into ansible folder
```bash
cd SysAdmCephCluster/ansible
```

#### Generate bastion ssh keys 
```bash
ansible-playbook -i inventory build_project/generate_ssh_keys.yaml --tags ssh_keys -vv
```
Example of a ansible command that generates the ssh keys that will be used to access all istances.

#### create tf state bucket, build tfvars and build inventory
```bash
ansible-playbook -i inventory build_project/main.yaml  --extra-vars "command=apply"  -vv
```
Example of a ansible command that generates the inventory used by ansible to retrieve all instances metadate deployed in the porject. The data used from that API is the private IP address, the public IP address from bastion host and the instances hostnames.
Furthermore, this playbook also generates the tf vars used in project and the values are present into `ceph_cluster_configuration.yml` in order to make tre poject as dinamic as possible. Finnaly, the tf state bucket that will store all modules tfstates is also created by this playbook and executes a terraform command. this ansible command recives a command and is accepted the option `apply` or `destroy`

#### execute terraform to setup the whole infrastructure infrastructure
##### enter into terraform folder
```bash
cd SysAdmCephCluster/terraform
```
```bash
./executor.sh base apply
./executor.sh cephCluster apply
```

#### generate ssh proxy locally
```bash
ansible-playbook -i inventory bastion/build_local_proxy.yaml --tags proxy_jump --ask-become-pass  -vv
```
##### execute common configurations amoung all hosts
##### command to apply in every node.
```bash
ansible-playbook -i inventory common/init.yaml -l all --tags ceph_init --key-file "../ssh_keys/idrsa"  -vv
```

##### configure ceph monitor node
```bash
ansible-playbook -i inventory cephCluster/cephMonitor.yaml -l monitor --tags ceph_monitor_admin,ceph_monitor,ceph_osd,ceph_rbd,ceph_manager   --key-file "../ssh_keys/idrsa"  -vv
```

##### configure ceph manager nodes
```bash
ansible-playbook -i inventory cephCluster/cephManager.yaml -l manager --tags ceph_manager,ceph_manager_dashboard --key-file "../ssh_keys/idrsa"  -vv
```

##### configure osd node
```bash
ansible-playbook -i inventory cephCluster/cephOSD.yaml -l osd --tags ceph_osd --key-file "../ssh_keys/idrsa"  -vv
```
##### configure rbd node
```bash
ansible-playbook -i inventory cephCluster/cephRBD.yaml -l rbd --tags ceph_rbd --key-file "../ssh_keys/idrsa"  -vv
```

### Usefull commands
##### Remote access bastion host
```bash
cd SysAdmCephCluster
ssh -i ssh_keys/idrsa  bastion@(bastion public ip)
```
##### Remote access ceph instances
```bash
cd SysAdmCephCluster/ansible
ssh (ceph instance private ip)
```
##### ceph commands to check the cluster status
```bash
ceph -s
ceph osd tree
ceph df 
ceph osd df 
```


##### access dashboard via proxyjump
```bash
cd SysAdmCephCluster
ssh -i ssh_keys/idrsa -L 127.0.0.1:8443:(ceph_manager_private_address):8443 bastion@(bastion_public_address)
```

## Destroy cluster

```bash
cd SysAdmCephCluster/terraform

./executor.sh cephCluster destroy
./executor.sh base destroy
```

## Destroy tf state bucket

```bash
cd SysAdmCephCluster/ansible

ansible-playbook -i inventory build_project/main.yaml  --extra-vars "command=destroy"  -vv
```
