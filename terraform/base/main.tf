module "Network"{
    source = "../modules/gcp/network"

    # vpc
    project_name = var.project_id
    vpc_name =  "ceph-cluster-vpc"
    auto_create_subnetworks = false
    delete_default_routes_on_create = true
    routing_mode = "REGIONAL"
    region = var.region

    # publicly accessed bastion subnet
    pub_subnet_name = "pub-subnet"
    pub_subnet_priv_ip_cidr = "192.168.0.0/24"
    pub_subnet_purpose  = "PRIVATE"

    # priv subnet
    private_subnet_name = "priv-subnet"
    private_subnet_ip_cidr = "10.10.0.0/24"
    private_subnet_purpose  = "PRIVATE"

    # default route
    route_name = "ceph-cluster-default-igw"
    route_priority = 1000
    dest_ip_range = "0.0.0.0/0"
}

module "FirewallRule_private" {
    source = "../modules/gcp/firewall_rules"
    rule_name = "private-network-rules"
    vpc_id = module.Network.vpc_id
    protocol = "tcp"
    ports=["22","443", "80"]
    source_ranges = ["192.168.0.0/24"]
    desitnation_ranges = ["0.0.0.0/0"]
    project_id = var.project_id
    depends_on = [module.Network ]
}

module "FirewallRule_public" {
    source = "../modules/gcp/firewall_rules"
    rule_name = "public-network-rules"
    vpc_id = module.Network.vpc_id
    protocol = "tcp"
    ports=["22"]
    source_ranges = ["0.0.0.0/0"]
    desitnation_ranges = ["0.0.0.0/0"]
    project_id = var.project_id
    depends_on = [module.Network ]
}

resource "google_service_account" "service_account" {
  account_id   = "bastion"
  display_name = "bastion"
}

module "bastion" {
    source = "../modules/gcp/compute"
    num_instances = 1
    vm_name = "bastion"
    machine_type = "f1-micro"
    vpc_id = module.Network.vpc_id
    subnet = "pub-subnet"
    image = "debian-cloud/debian-11"
    provisioning_model = "SPOT"
    tags = ["ssh", "bastion"]
    scopes = ["cloud-platform"]
    public_instance = true
    #users_ssh_info = join(",\n", [for key, value in var.users_ssh_info : "${key}:${value} ${key}"])
    depends_on = [module.Network ]
    ssh_pub = file(var.path_local_public_key)
    username = "bastion"
}
