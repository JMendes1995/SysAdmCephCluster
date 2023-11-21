data "google_compute_default_service_account" "default" {
}

data "google_compute_zones" "available_zones" {
}


resource "google_compute_instance" "public_vm" {
    count = var.public_instance == true ? var.num_instances : 0
    name         = "${var.vm_name}-${count.index}"
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
    # to be removed for test porpuse
    attached_disk {
      source      = google_compute_disk.default.id
      device_name = google_compute_disk.default.name
    }
    network_interface {
      network = var.vpc_id
      access_config {}
      subnetwork = var.subnet
    }

    tags = var.tags
    #metadata = {
    #  "ssh-keys" =  var.users_ssh_info
    #}
    metadata = {
      "ssh-keys" =  "${var.username}:${var.ssh_pub} ${var.username}:"
    }
    service_account {
      # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
      email  = data.google_compute_default_service_account.default.email
      scopes = var.scopes
    }
}

resource "google_compute_disk" "storage_divice" {
  count = var.storage_device_number
  name = "${var.storage_device_name}-${count.index}"
  type =  storage_device_type
  zone = data.google_compute_zones.available_zones.names[count.index]
  size = var.storage_device_size
}


resource "google_compute_instance" "private_vm" {
    count = var.public_instance == true ? 0 : var.num_instances
    name         = "${var.vm_name}-${count.index}"
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
      subnetwork = var.subnet
    }
    attached_disk {
      source      = google_compute_disk.storage_divice.id
      device_name = google_compute_disk.storage_divice.[].name
    }
    tags = var.tags
    metadata = {
      "ssh-keys" =  "${var.username}:${var.ssh_pub} ${var.username}:"
    }
    service_account {
      # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
      email  = data.google_compute_default_service_account.default.email
      scopes = var.scopes
    }
}