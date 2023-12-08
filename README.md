# SysAdmCephCluster
###### Table of contents
1. [Architecture diagram](#diagram)
    1. [Architecture decisions and considerations](#arch_decesions)
    2. [Project components](#p_components)
    3. [Terraform structure](#tf)
    4. [Ansible structure](#ansible)
2. [Configurations](#configs)
3. [Backup statagies](#bk)
4. [System Troubleshooting](#trbl)
5. [System Recovery](#recovery)
6. [How to setup the ceph cluster project](#setup)

### Architecture diagram <a name="diagram"></a>
![image info](./resources/ceph_cluster_diagram.png)
#### Architecture decisions <a name="arch_decesions"></a>
In this project, our team established various guidelines that have culminated in the present architecture. One of the essential principles we incorporated is the need for a secure architecture. In a real-life scenario, every cluster must have private access. According to cloud provider’s best practices, the default Virtual Private Cloud (VPC) should only be utilized for testing purposes as it lacks constraints and security measures, posing a severe security risk. Consequently, for this project was created a  **Virtual Private Cloud** with 2 separated private subnets 192.168.0.0/24 and 10.10.0.0/24. The subnet 192.168.0.0/24, is publically accessible as bastion host serves as a proxy jump from the Administrator to the Ceph cluster, while a firewall rule allows inbound public traffic from the Administration public IP address on port 22. Additionally, this subnet was created with the necessary security measures to ensure that the public access does not compromise the overall security of the architecture.

Additionaly, the subnet 10.10.0.0/24 is a private subnet that will host the entire ceph architecture. Therefore, having these resources exposed publicly would pose a significant risk. we defined this subnet as private by implying firewall rules that only allow inbound requests from 192.168.0.0/24 network. However the ceph nodes require access to internet to pull software. Therefore was additionaly createa a NAT router that grants outbound connectivity for ceph instances.

To deploy the architecture into Google Cloud it has decided to divide the deployment into tow separate phases: infrastructure provisioning and configuration management. Terraform was used as an infrastructure as code tool for infrastructure provisioning. While ansible was used for, for configuration management. The purpose of this segmentation is to enhance the agility towards the architecture configuration. In case a node faces issues, with Ansible,  it is possible to operate isolated or multiple commands based on defined workflows, tags, and playbook. If the configuration was implied using cloud-init on Terraform, it would be impossible to modify the instance without destroying it and causing downtime.

#### Terraform structure <a name="tf"></a>
The current project utilizes a terraform structure based on modules, with the `executer.sh` script serving as the primary interface in place of direct terraform commands. This script executes terraform actions based on an input module and operation type (apply or destroy) and thereby reduces the number of required input parameters. Furthermore, the script automatically initializes Terraform and includes Terraform parameters that facilitate the use of a custom tf state backend, which points to a bucket housing tf states. This approach supports concurrent work by two team members on the project without the risk of interfering with each other's resources. 
The terraform actions performed within the `executer.sh` script occur within an ephemeral target folder with a single execution timespan, during which files from the targeted module and the common folder are copied. The common folder contains terraform variables, backend configuration, and terraform providers. It is worth noting that prior to initiating the project's module provisioning, is required a preemptive provisioning of a bucket that will function as the terraform state backend.

Managing and maintaining infrastructure that involves multiple cloud resources can be overwhelming. To make it easier, cloud architect's commonly use modular approaches reduce the number of duplicated resources, generate fewer dependencies and simplify the creation of resources from the same type. In the presented architecture the resources are located in the “modules” folder and are segregated based on whether they are networking, computing, security or storage resources.

Additionally, the modules available to be provisioned are the “base” module which provisions the VPC, the subnets the nat resources and the firewall rules. The second module is the cephCluster which is responsible for provisioning virtual machine instances and HDD storage intrinsically correlated with the Ceph cluster.


<details>
  <summary>terraform directory structure</summary>
  
  ```bash
    terraform
    ├── base
    │   ├── locals.tf
    │   ├── main.tf
    │   └── outputs.tf
    ├── cephCluster
    │   ├── main.tf
    │   └── remote_state.tf
    ├── common
    │   ├── data.tf
    │   ├── providers.tf
    │   ├── tfstate_backend.tf
    │   └── variables.tf
    ├── env.tfvars
    ├── executor.sh
    ├── modules
    │   └── gcp
    │       ├── compute
    │       │   ├── private_vm
    │       │   │   ├── main.tf
    │       │   │   ├── outputs.tf
    │       │   │   └── variables.tf
    │       │   ├── public_vm
    │       │   │   ├── main.tf
    │       │   │   └── variables.tf
    │       │   └── storage
    │       │       ├── main.tf
    │       │       ├── outputs.tf
    │       │       └── variables.tf
    │       ├── firewall_rules
    │       │   ├── main.tf
    │       │   └── variables.tf
    │       ├── network
    │       │   ├── nat
    │       │   │   ├── main.tf
    │       │   │   └── variables.tf
    │       │   ├── subnet
    │       │   │   ├── main.tf
    │       │   │   └── variables.tf
    │       │   └── vpc
    │       │       ├── main.tf
    │       │       ├── outputs.tf
    │       │       └── variables.tf
    │       └── storage_bucket
    │           ├── main.tf
    │           └── variables.tf
    └── tf_state_bucket
        ├── main.tf
        ├── providers.tf
        ├── terraform.tfstate
        ├── terraform.tfstate.backup
        └── variables.tf
18 directories, 43 files
  ```
</details>

#### Ansible structure <a name="ansible"></a>
As previously indicated, using Ansible allows the creation of configuration workflows based on playbooks and tags. Ansible effectively  communicates with the google cloud API obtaining the instances metadata which contains the private and public IP address of every node and groups them according to their names.

The “generate_ssh_keys” playbook contained in the “build_projcet” folder generates a bastion SSH key pair used for authenticating instance.  the “main.yaml” playbook generates the “env.tfvars” file with project configurations based on “ceph_cluster_configuration.yaml” located in the project root folder. It also executes the terraform commands to create the tf state bucket.

Additionally, the “build_local_proxy.yaml” playbook, modifies locally the /etc/ssh/ssh_config file to allow jumping to 10.10.0.0/24 private subnet using the bastion host.

Lastly, within the cephCluster folder are present the playbooks responsible for configuring the Ceph cluster separated depending of his role.

<details>
  <summary>ansible directory structure</summary>

  ```bash
ansible
├── ansible.cfg
├── bastion
│   └── build_local_proxy.yaml
├── build_project
│   ├── generate_ssh_keys.yaml
│   └── main.yaml
├── cephCluster
│   ├── cephManager.yaml
│   ├── cephMonitor.yaml
│   ├── cephOSD.yaml
│   └── cephRBD.yaml
├── common
│   └── init.yaml
└── inventory
    └── inventory.gcp.yml

6 directories, 10 files
  ```
</details>

### Configurations <a name="configs"></a>
### Backup strategies <a name="bk"></a>
For scope was tasked to crate 2 backup mechanisms

### Troubleshooting steps <a name="trbl"></a>
### System Recovery <a name="recovery"></a>

## How to setup the ceph project <a name="setup"></a>
### Prerequisites<a name="req"></a>
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
Example of a ansible command that generates the inventory used by ansible to retrieve all instances metadata deployed in the project. The data used from that API are: The private IP address from ceph nodes, the public IP address from bastion host and the instance hostnames.
Furthermore, this playbook also generates the tf vars used by the terraform in this project.

The variables used in both ansible and terraform are set on `ceph_cluster_configuration.yml`  file in order to make the project dynamic and adjustable to everyone.
Finally, it also creates the tf_state bucket that will store all terraform states generated by each module that terraforms provisiones.
This ansible execution accepts as a command the option `apply` or `destroy`.


#### Execute terraform to setup the whole infrastructure infrastructure
##### Enter into terraform folder
```bash
cd SysAdmCephCluster/terraform
```
```bash
./executor.sh base apply
./executor.sh cephCluster apply
```

After the creation of the tfstate bucket, the following step is to provision the whole infrastructure that will host the ceph cluster. The infrastructure is splitted into 2 modules. The **base** and the **cephCluster**. Whereas the base module file is responsible for provision 1 VPC, 2 Subnets (private and public access subnet), firewall rules, Nat router and bastion host. On other hand, the cephCluster module is responsible for provisioning all resources directly related with the ceph cluster such as the Manager and monitor nodes, the OSD, RDB, and 2 HDD volumes per OSD node.


##### Generate ssh proxy locally
```bash
ansible-playbook -i inventory bastion/build_local_proxy.yaml --tags apply --ask-become-pass  -vv
```

In order to access all the infrastructure, hosted in the private subnet (10.10.0.0/24), for security purpuse is crucial to create a proxy jump between the localhost where the ansible is being executed to the destination network. Therefore, regarding that bastion host that is accessible from the public network on port 22 is being used as a proxy to jump to the Ceph Network.
The following image shows an example of a ssh_config file after executing the ansible command.
In this ansible command is passed the `proxy_jump` tag, and the `--ask-become-pass` to escalate priveligies to write into `/etc/ssh/ssh_config` file
<details open>
  <summary>/etc/ssh/ssh_config example</summary>
<IMG src=./resources/ssh_proxy_bastion.png></IMG>
</details>


##### Execute common configurations among all hosts
```bash
ansible-playbook -i inventory common/init.yaml -l all --tags ceph_init --key-file "../ssh_keys/idrsa"  -vv
```

​​After being granted connectivity to the entire environment it will begin the initial configurations with the assistance of ansible. Those configurations will grant the authentication between instances. Thus, will be copied the ssh keys generated previously in the beginning of the project to each instance to the bastion home directory.
In this ansible command is passed the parameters `-l all` to force the execution in every instance, `--tags ceph_init` and the reference to the private ssh key used to authenticate in the instances `--key-file "../ssh_keys/idrsa"`.

##### Configure ceph monitor node
```bash
ansible-playbook -i inventory cephCluster/cephMonitor.yaml -l monitor --tags ceph_monitor,ceph_osd,ceph_rbd,ceph_manager,backup   --key-file "../ssh_keys/idrsa"  -vv
```
The cephMonitor playbook configures the monitor node, and send remotely to the other ceph instances the ceph config file and the keyring to join the ceph cluster.

##### Configure ceph manager nodes
```bash
ansible-playbook -i inventory cephCluster/cephManager.yaml -l manager --tags ceph_manager --key-file "../ssh_keys/idrsa"  -vv
```
##### Configure ceph manager dashboard
```bash
ansible-playbook -i inventory cephCluster/cephManager.yaml -l manager --tags ceph_manager_dashboard --key-file "../ssh_keys/idrsa"  -vv
```
The cephManager playbook configures the manager nodes and enable the ceph dashboard. Based on the tag provided will be configured the ceph_manager if provided the tag **ceph_manager**  whereas if the tag provided is **ceph_manager_dashboard** will enable the dashboard plugin and configureing the user and password.


##### configure osd node
```bash
ansible-playbook -i inventory cephCluster/cephOSD.yaml -l osd --tags ceph_osd --key-file "../ssh_keys/idrsa"  -vv
```
The cephOSD playbook formats the entire HDD volume and mount it on `/dev/sdb1`, `/dev/sdc1`, ...

<details open>
  <summary>OSD Node status</summary>
<IMG src=./resources/osd.png></IMG>
</details>

##### Configure rbd node
```bash
ansible-playbook -i inventory cephCluster/cephRBD.yaml -l rbd --tags ceph_rbd,database,backup --key-file "../ssh_keys/idrsa"  -vv
```
The CephRDB playbook
<details open>
  <summary>Client (RDB Node)</summary>
<IMG src=./resources/rdb_nodes.png></IMG>
</details>


The cephRBD playbook mainly creates the RBD Pool, maps the block device, format the volume in XFS format, and mount the volume `/dev/rbd0` into a mounted directory `/mnt`.
Furthermore, when is additionaly inserted **database** tag will install postgres, sync the default postgres data from `/var/lib/postgresql/16/main/` to `/mnt/database/lib/postgresql/16/main/`, modifies the data directory parameter from postgres configuration file and create a ramdom table with 1000 rows with ramdom data. On other hand, with the tag **backup** the playbook will create a directory (`/home/bastion/postgres/backup`) where is located the database backups, creates a crontab job that every minute generates a backup file compressed in `tar.gz`` format.

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


##### Access dashboard via proxyjump
```bash
cd SysAdmCephCluster
ssh -i ../ssh_keys/idrsa -L 127.0.0.1:8443:(ceph_manager_private_address):8443 bastion@(bastion_public_address)
```


### Restoring process
##### restore ceph monitor node
```bash
ansible-playbook -i inventory cephCluster/cephManager.yaml -l manager --tags ceph_monitor_restore --key-file "../ssh_keys/idrsa"  -vv
```
The recovery of monitor functionalites is made
##### restore database in rdb node
```bash
ansible-playbook -i inventory cephCluster/cephRBD.yaml -l rbd --tags restore --key-file "../ssh_keys/idrsa"  -vv
```

### Destroy cluster

```bash
cd SysAdmCephCluster/terraform

./executor.sh cephCluster destroy
./executor.sh base destroy
```

### Destroy tf state bucket

```bash
cd SysAdmCephCluster/ansible

ansible-playbook -i inventory build_project/main.yaml  --extra-vars "command=destroy"  -vv
```


#### restore monitor

ansible-playbook -i inventory cephCluster/cephManager.yaml -l manager --tags ceph_monitor_restore --key-file "../ssh_keys/idrsa"  -vv

### postgres commands
<details open>
  <summary>fist 50 results from dummy database</summary>
    
  ```bash 

  root@rbd1:~# sudo -u postgres psql -c "select * from randomtable limit 50;"
   id |           random_text            |   random_number    | random_integer | random_date
  ----+----------------------------------+--------------------+----------------+-------------
    1 | b06af2d3106b653d77a0625eb1cafb2a |  196.1698110577663 |             88 | 2567-10-01
    2 | 60e44f1937935bb73bd46b4c6ae5b1b8 | 187.50099342575544 |            507 | 2419-08-10
    3 | 05f0476cc36b58b233b9116a82100b78 |  642.6980756701013 |             23 | 2506-11-14
    4 | e0a0d554c343e7c7e1cf312ff780646d |  92.62785448726873 |            514 | 2432-04-26
    5 | 2e3beff40cb537281d1a1ce481509686 |  87.55502664444026 |            582 | 2578-02-14
    6 | 5f40d2945c8443dc7e64bbaad71db96c |  412.5930307965775 |            711 | 2236-07-17
    7 | d4f49b3c04dc6b8f0052aabb952d078a |  724.6586797408154 |            279 | 2766-07-23
    8 | 8c5325d8445178dc423270824c05a4bf | 165.49187002089784 |            229 | 2755-12-01
    9 | 6460f21ab04f7a3d58b40ea76ea4d125 |    779.99208007664 |            852 | 2163-12-10
   10 | 8192919c71cd29220c1c46169afb080d |  961.6014742822747 |            287 | 2723-01-12
   11 | 3b95a5bc1ff228bb85ba0db8200853ac | 488.08139204023627 |            317 | 2213-12-13
   12 | b6b81856cb1b627e919712b2387b0295 |  770.0333900128958 |            624 | 2330-02-08
   13 | 82ba1d7159d979225bac2dd197784086 | 360.72665659398575 |            936 | 2447-04-19
   14 | 230f5cdb59dba8bdddd393be52bd0338 |  7.678168694612797 |            424 | 2337-04-15
   15 | 60a9d75251a602d34abdcfa258d4e687 |  544.3859142302358 |            941 | 2005-05-12
   16 | 865768fd8df6a7a88681a1245d95b1e3 |  145.1951243013969 |            508 | 2174-01-18
   17 | f8fcd87d6bd84a431e6f4eac494ef6c2 |  265.7649323542377 |            741 | 2145-01-25
   18 | ba05450928345f17e083019f5f2c962b |  685.9257099105307 |            271 | 2550-02-19
  ```
</details>

<details open>
  <summary>crontab logs</summary>

  ```bash root@rbd1:~# tail -f /home/bastion/crontab.log
  number of backups =>0
  postgresql service is =>active
  number of backups =>1
  postgresql service is =>active
  number of backups =>2
  postgresql service is =>active
  number of backups =>3
  postgresql service is =>active
  number of backups =>4
  postgresql service is =>active
  number of backups =>5
  postgresql service is =>active
  number of backups exceeds maximum of 5
  removing oldest backup database_bk_1702043521.tar.gz
  generating backup => database_bk_1702043821.tar.gz
  number of backups =>5
  postgresql service is =>active
  number of backups exceeds maximum of 5
  removing oldest backup database_bk_1702043581.tar.gz
  generating backup => database_bk_1702043881.tar.gz
  number of backups =>5
  postgresql service is =>inactive
  number of backups =>5
  postgresql service is =>inactive
  ```
</details>