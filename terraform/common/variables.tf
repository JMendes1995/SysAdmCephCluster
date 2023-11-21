variable "tfstate_bucket_name" {}
variable "project_name" {}
variable "project_id" {}
variable "region" {}
variable "ip_isp_pub" {}
variable "path_local_public_key" {
  sensitive = true
}