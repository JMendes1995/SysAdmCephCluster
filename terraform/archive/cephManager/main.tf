module "CephManager" {
    source = "../modules/gcp/compute/private_vm"

    num_instances       = var.manager_nodes_number
    vm_name             = "manager"
    machine_type        = var.manager_machine_type
    vpc_id              = data.terraform_remote_state.base_tfstate.outputs.vpc_id
    subnet              = data.terraform_remote_state.base_tfstate.outputs.private_subnet_name
    public_instance     = false
    image               = var.image
    provisioning_model  = var.manager_provisioning_model
    tags                = var.manager_tags
    scopes              = var.scopes
    ssh_pub             = file(var.path_local_public_key)
    username            = var.username
    defaul_sa_name      = data.google_compute_default_service_account.default_sa.email
    available_zones     = data.google_compute_zones.available_zones.names.*
}
