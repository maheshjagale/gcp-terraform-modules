terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id

    dynamic "access_config" {
      for_each = var.create_public_ip ? [1] : []
      content {
        nat_ip = var.static_ip != null ? var.static_ip : null
      }
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  metadata = var.metadata

  labels = var.labels

  tags = var.tags
}

output "instance_id" {
  value       = google_compute_instance.vm.id
  description = "Instance ID"
}

output "instance_self_link" {
  value       = google_compute_instance.vm.self_link
  description = "Instance self link"
}

output "private_ip" {
  value       = google_compute_instance.vm.network_interface[0].network_ip
  description = "Private IP address"
}

output "public_ip" {
  value       = try(google_compute_instance.vm.network_interface[0].access_config[0].nat_ip, null)
  description = "Public IP address"
}
