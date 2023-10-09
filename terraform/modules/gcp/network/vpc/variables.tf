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
