# create vpc
module "vpc" {
    source = "../modules/gcp/network/vpc"

    project_name = var.project_id
    vpc_name =  "ceph-cluster-vpc"
    auto_create_subnetworks = false
    delete_default_routes_on_create = true
    routing_mode = "REGIONAL"
}
# create subnets
module "Subnets" {
    source = "../modules/gcp/network/subnets"

    subnet_name = "ceph-cluster-subnet"
    region = var.region
    ip_cidr = "10.10.0.0/24"
    subnet_purpose  = "PRIVATE"
    vpc_id = module.vpc.vpc_id
    depends_on = [ module.vpc ]
}
# create routes
module "DefaultRroute" {
    source = "../modules/gcp/network/routes"
    route_name = "ceph-cluster-default-igw"
    vpc_id = module.vpc.vpc_id
    route_priority = 1000
    dest_ip_range = "0.0.0.0/0"
    depends_on = [ module.vpc, module.Subnets ]
}

module "FirewallRule" {
    source = "../modules/gcp/network/firewall_rules"
    rule_name = "ceph-cluster-allow-ssh"
    vpc_id = module.vpc.vpc_id
    protocol = "tcp"
    ports=["22","443"]
    source_ranges = ["149.90.53.1/32"]
    desitnation_ranges = ["0.0.0.0/0"]
    project_id = var.project_id
    depends_on = [ module.vpc, module.Subnets ]
}

module "vm" {
    source = "../modules/gcp/compute"
    num_instances = 1
    vm_name = "test-vm"
    machine_type = "f1-micro"
    vpc_id = module.vpc.vpc_id
    subnet = "ceph-cluster-subnet"
    depends_on = [ module.vpc, module.Subnets ]
}


