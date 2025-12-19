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

resource "google_compute_instance" "container_vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = var.container_image
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id
  }

  metadata = merge(
    var.metadata,
    {
      "gce-container-declaration" = file(var.container_declaration_file)
    }
  )

  labels = var.labels
}

output "instance_id" {
  value       = google_compute_instance.container_vm.id
  description = "Container VM instance ID"
}
