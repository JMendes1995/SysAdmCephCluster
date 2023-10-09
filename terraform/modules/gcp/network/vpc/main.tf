resource "google_compute_network" "vpc" {
  name                              = var.vpc_name
  auto_create_subnetworks           = var.auto_create_subnetworks
  project                           = var.project_name
  delete_default_routes_on_create   = var.delete_default_routes_on_create
  routing_mode                      = var.routing_mode
}
