
module "vm" {
    source = "../modules/gcp/compute"
    num_instances = 1
    vm_name = "test-vm"
    machine_type = "f1-micro"
    vpc_id = data.terraform_remote_state.base_tfstate.outputs.vpc_id
    subnet = "ceph-cluster-subnet"
    ssh_key_pub = ""
    image = "debian-cloud/debian-11"
    provisioning_model = "SPOT"
    tags = ["ssh"]
    scopes = ["cloud-platform"]
    users_ssh_info = join(",\n", [for key, value in var.users_ssh_info : "${key}:${value} ${key}"])
}