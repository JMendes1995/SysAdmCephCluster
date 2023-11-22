module "Volumes"{
    source = "../modules/gcp/compute/storage"

    storage_device_number   = 1
    storage_device_name     = "ceph-storage"
    storage_device_type     = "pd-standard"
    storage_device_size     = 5
    available_zones         = data.google_compute_zones.available_zones.names.*

}
module "CephObjectStorageDevice" {
    source = "../modules/gcp/compute/private_vm"

    num_instances   = 1
    vm_name             = "osd-node"
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
    defaul_sa_name      = data.google_compute_default_service_account.default_sa.email
    available_zones     = data.google_compute_zones.available_zones.names.*
    storage_devices     = module.Volumes.volume_ids
}
