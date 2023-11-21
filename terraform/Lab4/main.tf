
module "debian" {
    source = "../modules/gcp/compute"
    num_instances = 1
    vm_name = "debian"
    machine_type = "f1-micro"
    vpc_id = data.terraform_remote_state.base_tfstate.outputs.vpc_id
    subnet = "priv-subnet"
    public_instance = false
    image = "debian-cloud/debian-11"
    provisioning_model = "SPOT"
    tags = ["ssh"]
    scopes = ["cloud-platform"]
    #users_ssh_info = join(",\n", [for key, value in var.users_ssh_info : "${key}:${value} ${key}"])
    ssh_pub = file(var.path_local_public_key)
    username = "bastion"
    region = "${var.region}-a"
}


module "fedora_server" {
    source = "../modules/gcp/compute"
    num_instances = 0
    vm_name = "fedora-server"
    machine_type = "f1-micro"
    vpc_id = data.terraform_remote_state.base_tfstate.outputs.vpc_id
    subnet = "priv-subnet"
    public_instance = false
    image = "fedora-cloud/fedora-cloud-38"
    provisioning_model = "SPOT"
    tags = ["ssh"]
    scopes = ["cloud-platform"]
    #users_ssh_info = join(",\n", [for key, value in var.users_ssh_info : "${key}:${value} ${key}"])
    ssh_pub = file(var.path_local_public_key)
    username = "bastion"
    region = "${var.region}-a"
}