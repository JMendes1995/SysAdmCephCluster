variable "project_name" {
    type = string
}
variable "vpc_name" {
    type = string
}
variable "auto_create_subnetworks" {
    type=bool
}
variable "delete_default_routes_on_create" {
    type = bool
}
variable "routing_mode" {
    type = string
}
variable "region" {
    type = string  
}
variable "private_subnet_name" {
    type = string  
}
variable "private_subnet_purpose" {
    type = string
}
variable "route_name" {
  type = string
}
variable "route_priority" {
  type = number
}
variable "dest_ip_range" {
  type = string
}
variable "pub_subnet_name"{
    type = string
}
variable "pub_subnet_priv_ip_cidr"{
    type = string
}
variable "pub_subnet_purpose"{
    type = string
}
variable "private_subnet_ip_cidr"{
    type = string
}