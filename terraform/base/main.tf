####################################################
###################### VPC #########################
####################################################
module "Network"{
    source = "../modules/gcp/network/vpc"

    project_name                    = var.project_id
    vpc_name                        =  "ceph-cluster-vpc"
    auto_create_subnetworks         = false
    delete_default_routes_on_create = true
    routing_mode                    = "REGIONAL"
    route_name                      = "ceph-cluster-default-igw"
    next_hop_gateway                = "default-internet-gateway"
    route_priority                  = 1000
    dest_ip_range                   = "0.0.0.0/0"
}

####################################################
################## Private Subnet ##################
####################################################
module "PrivateAccessSubnet" {
    source = "../modules/gcp/network/subnet"
    
    vpc_id          = module.Network.vpc_id
    subnet_name     = local.private_subnet_name
    ip_cidr         = "10.10.0.0/24"
    subnet_purpose  = "PRIVATE"
    region          = var.region
    
}

module "NatGateway"{
    source = "../modules/gcp/network/nat"

    vpc_id              = module.Network.vpc_id
    project_name        = var.project_id
    router_name         = "natgw-router"
    region              = var.region
    nat_name            = "natgw"
    allocate_option     = "AUTO_ONLY"
    ranges_to_nat       = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    depends_on = [module.Network, 
                  module.PrivateAccessSubnet]
}

module "FirewallRulePrivate" {
    source = "../modules/gcp/firewall_rules"

    rule_name           = "private-network-rules"
    vpc_id              = module.Network.vpc_id
    protocol            = "tcp"
    ports               = ["22","443", "80", "8443", "3300", "6789","6800-7100" ]
    source_ranges       = ["192.168.0.0/24", "10.10.0.0/24"]
    desitnation_ranges  = ["0.0.0.0/0"]
    project_id          = var.project_id
    
    depends_on = [module.Network]
}

module "PublicAccessSubnet"{
    source = "../modules/gcp/network/subnet"

    vpc_id          = module.Network.vpc_id
    subnet_name     = "pub-subnet"
    ip_cidr         = "192.168.0.0/24"
    subnet_purpose  = "PRIVATE"
    region          = var.region
    
    depends_on = [module.Network]
}

module "FirewallRulePublic" {
    source = "../modules/gcp/firewall_rules"
    
    rule_name           = "public-network-rules"
    vpc_id              = module.Network.vpc_id
    protocol            = "tcp"
    ports               = ["22"]
    source_ranges       = concat(var.ip_isp_pub, ["10.10.0.0/24"])
    desitnation_ranges  = ["0.0.0.0/0"]
    project_id          = var.project_id

    depends_on = [module.Network]
}

module "Bastion" {
    source = "../modules/gcp/compute/public_vm"
    
    num_instances       = 1

    vm_name             = "bastion"
    machine_type        = var.bastion_machine_type
    vpc_id              = module.Network.vpc_id
    subnet              = "pub-subnet"
    image               = var.image
    provisioning_model  = var.bastion_provisioning_model
    tags                = var.bastion_tags
    scopes              = var.scopes
    public_instance     = true
    ssh_pub             = file(var.path_local_public_key)
    username            = var.username

    defaul_sa_name      = data.google_compute_default_service_account.default_sa.email
    available_zones     = data.google_compute_zones.available_zones.names.*
    
    depends_on = [module.Network, 
                  module.PublicAccessSubnet]
}
