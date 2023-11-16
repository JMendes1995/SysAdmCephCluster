resource "google_compute_network" "vpc" {
  name                              = var.vpc_name
  auto_create_subnetworks           = var.auto_create_subnetworks
  project                           = var.project_name
  delete_default_routes_on_create   = var.delete_default_routes_on_create
  routing_mode                      = var.routing_mode
}
resource "google_compute_subnetwork" "private_subnet" {
  name             = var.private_subnet_name
  region           = var.region
  ip_cidr_range    = var.private_subnet_ip_cidr
  purpose          = var.private_subnet_purpose
  network          = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "bastion_subnet" {
  name             = var.pub_subnet_name
  region           = var.region
  ip_cidr_range    = var.pub_subnet_priv_ip_cidr
  purpose          = var.pub_subnet_purpose
  network          = google_compute_network.vpc.id
}

resource "google_compute_route" "route" {
  name        = var.route_name
  dest_range  = var.dest_ip_range
  network     = google_compute_network.vpc.id
  priority    = var.route_priority
  next_hop_gateway = "default-internet-gateway"
}


resource "google_compute_router" "router" {
  provider = google-beta
  project  = var.project_name
  name     = "pub-router"
  region   = google_compute_subnetwork.private_subnet.region
  network  = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-router"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  #log_config {
  #  enable = false
    #filter = "ERRORS_ONLY"
  #}
  depends_on = [google_compute_router.router,  
              google_compute_subnetwork.private_subnet]
}