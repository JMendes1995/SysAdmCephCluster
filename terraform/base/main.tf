module "Network"{
    source = "../modules/gcp/network"

    # vpc
    project_name = var.project_id
    vpc_name =  "ceph-cluster-vpc"
    auto_create_subnetworks = false
    delete_default_routes_on_create = true
    routing_mode = "REGIONAL"

    #subnet
    subnet_name = "ceph-cluster-subnet"
    region = var.region
    ip_cidr = "10.10.0.0/24"
    subnet_purpose  = "PRIVATE"

    # default route
    route_name = "ceph-cluster-default-igw"
    route_priority = 1000
    dest_ip_range = "0.0.0.0/0"
}

module "FirewallRule" {
    source = "../modules/gcp/firewall_rules"
    rule_name = "ceph-cluster-allow-ssh"
    vpc_id = module.Network.vpc_id
    protocol = "tcp"
    ports=["22","443"]
    source_ranges = [var.ip_isp_pub]
    desitnation_ranges = ["0.0.0.0/0"]
    project_id = var.project_id
    depends_on = [module.Network ]
}


