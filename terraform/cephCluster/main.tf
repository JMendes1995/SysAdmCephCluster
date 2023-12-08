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
    
    packages            = "ceph ceph-mgr-dashboard rsync"
}




module "CephMonitor" {
    source = "../modules/gcp/compute/private_vm"

    num_instances       = var.monitor_nodes_number
    vm_name             = "monitor"
    machine_type        = var.monitor_machine_type
    vpc_id              = data.terraform_remote_state.base_tfstate.outputs.vpc_id
    subnet              = data.terraform_remote_state.base_tfstate.outputs.private_subnet_name
    public_instance     = false
    image               = var.image
    provisioning_model  = var.monitor_provisioning_model
    tags                = var.monitor_tags
    scopes              = var.scopes
    ssh_pub             = file(var.path_local_public_key)
    username            = var.username
    defaul_sa_name      = data.google_compute_default_service_account.default_sa.email
    available_zones     = data.google_compute_zones.available_zones.names.*
    packages            = "ceph rsync"
    
}


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
    packages            = "ceph"
}



resource "google_compute_attached_disk" "attached_storage" {
  count = var.osd_volumes_per_instance*var.osd_nodes_number
  disk = element(module.Volumes.volume_ids, count.index) 
  instance = element(module.CephObjectStorageDevice.vm_ids, count.index)  
  zone = element(data.google_compute_zones.available_zones.names.*, count.index)

  lifecycle {
    ignore_changes = [instance]
  }
}

module "CephRBD" {
    source = "../modules/gcp/compute/private_vm"

    num_instances       = var.rbd_nodes_number
    vm_name             = "rbd"
    machine_type        = var.rbd_machine_type
    vpc_id              = data.terraform_remote_state.base_tfstate.outputs.vpc_id
    subnet              = data.terraform_remote_state.base_tfstate.outputs.private_subnet_name
    public_instance     = false
    image               = var.image
    provisioning_model  = var.rbd_provisioning_model
    tags                = var.rbd_tags
    scopes              = var.scopes
    ssh_pub             = file(var.path_local_public_key)
    username            = var.username
    defaul_sa_name      = data.google_compute_default_service_account.default_sa.email
    available_zones     = data.google_compute_zones.available_zones.names.*
    packages            = "ceph ceph-common"
}
