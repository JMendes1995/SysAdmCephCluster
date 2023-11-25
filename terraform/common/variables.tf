variable "tfstate_bucket_name" {}
variable "project_name" {}
variable "project_id" {}
variable "region" {}
variable "ip_isp_pub" {}
variable "path_local_public_key" {
  sensitive = true
}
variable "username"{}
variable "scopes"{}
variable "image"{}
variable "osd_nodes_number"{}
variable "osd_volumes"{}
variable "osd_volumes_per_instance"{}
variable "osd_volume_sizes_gb"{}
variable "osd_volume_type"{}
variable "osd_machine_type"{}
variable "osd_provisioning_model"{}
variable "osd_tags"{}
variable "rbd_nodes_number" {}
variable "rbd_machine_type"{}
variable "rbd_provisioning_model"{}
variable "rbd_tags"{}
variable "monitor_nodes_number" {}
variable "monitor_machine_type"{}
variable "monitor_provisioning_model"{}
variable "monitor_tags"{}
variable "manager_nodes_number" {}
variable "manager_machine_type"{}
variable "manager_provisioning_model"{}
variable "manager_tags"{}
variable "bastion_machine_type"{}
variable "bastion_provisioning_model"{}
variable "bastion_tags"{}
variable "service_account_file"{}