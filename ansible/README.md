# ansible infra configuration
## enter into ansible folder
```bash
cd SysAdmCephCluster/ansible
```
## setup bastion ssh keys 
```bash
ansible-playbook -i inventory/  playbooks/ssh_keys.yaml  -e command=init  -v
```
## setup tf_state cloud storage  
```bash
ansible-playbook -i inventory/  playbooks/tf_state.yaml  -e command=(apply or destroy) -v
```

## setup bastion initial configurations  
```bash
ansible-playbook -i inventory/  playbooks/bastion/init.yaml -v
```

## setup base infrastructure initial configurations  
```bash
ansible-playbook -i inventory/  playbooks/base.yaml  -e command=(apply or destroy) -v
```