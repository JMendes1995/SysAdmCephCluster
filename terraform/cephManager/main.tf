module "CephManager" {
    source = "../modules/gcp/compute"

    num_instances   = 1
    
    vm_name             = "manager-node"
    machine_type        = "f1-micro"
    vpc_id              = data.terraform_remote_state.base_tfstate.outputs.vpc_id
    subnet              = data.terraform_remote_state.base_tfstate.outputs.private_subnet_name
    public_instance     = false
    image               = "debian-cloud/debian-11"
    provisioning_model  = "SPOT"
    tags                = ["ssh"]
    scopes              = ["cloud-platform"]
    ssh_pub             = file(var.path_local_public_key)
    username            = "bastion"
    region              = "${var.region}-a"
}