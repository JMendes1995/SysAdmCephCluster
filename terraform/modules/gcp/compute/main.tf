data "google_compute_default_service_account" "default" {
}

data "google_compute_zones" "available_zones" {
}

resource "google_compute_instance" "test_vm" {
    count = var.num_instances
    name         = var.vm_name
    machine_type = var.machine_type
    zone = data.google_compute_zones.available_zones.names[count.index]
    boot_disk {
      initialize_params {
        image = var.image
      }
    }
    scheduling {
        provisioning_model = var.provisioning_model
        preemptible = true
        automatic_restart = false
    }
    network_interface {
      network = var.vpc_id
      access_config {}
      subnetwork = var.subnet
    }

    tags = var.tags
    metadata = {
      "ssh-keys" =  var.users_ssh_info
    }
    service_account {
      # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
      email  = data.google_compute_default_service_account.default.email
      scopes = var.scopes
    }
}