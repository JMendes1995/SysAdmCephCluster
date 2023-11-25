module "Volumes"{
    source = "../modules/gcp/compute/storage"

    storage_device_number   = var.osd_volumes
    storage_device_name     = "ceph-storage"
    storage_device_type     = var.osd_volume_type
    storage_device_size     = var.osd_volume_sizes_gb
    available_zones         = data.google_compute_zones.available_zones.names.*
}

module "CephObjectStorageDevice" {
    source = "../modules/gcp/compute/private_vm"

    num_instances       = var.osd_nodes_number
    vm_name             = "osd"
    machine_type        = var.osd_machine_type
    vpc_id              = data.terraform_remote_state.base_tfstate.outputs.vpc_id
    subnet              = data.terraform_remote_state.base_tfstate.outputs.private_subnet_name
    public_instance     = false
    image               = var.image
    provisioning_model  = var.osd_provisioning_model
    tags                = var.osd_tags
    scopes              = var.scopes
    ssh_pub             = file(var.path_local_public_key)
    username            = var.username
    defaul_sa_name      = data.google_compute_default_service_account.default_sa.email
    available_zones     = data.google_compute_zones.available_zones.names.*
}



resource "google_compute_attached_disk" "attached_storage" {
  count = var.osd_volumes_per_instance*var.osd_nodes_number
  disk = element(module.Volumes.volume_ids, count.index) 
  instance = element(module.CephObjectStorageDevice.vm_ids, count.index)  
  zone = element(data.google_compute_zones.available_zones.names.*, count.index)
}
