variable "num_instances" {
  type = number
}
variable "vm_name" {
  type = string
}
variable "machine_type" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet" {
  type = string
}
variable "ssh_key_pub"{
  type = string
}
variable "image"{
  type = string
}
variable "provisioning_model"{
  type = string
}
variable "tags"{
  type = list(string)
}

variable "scopes"{
  type = list(string)
}
variable "users_ssh_info"{
  type = string
}