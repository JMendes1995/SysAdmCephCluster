resource "google_compute_route" "route" {
  name        = var.route_name
  dest_range  = var.dest_ip_range
  network     = var.vpc_id
  priority    = var.route_priority
  next_hop_gateway = "default-internet-gateway"
}