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

locals {
  bastion_name = var.name != "" ? var.name : "bastion-${var.zone}"
}

# Service Account for Bastion Host
resource "google_service_account" "bastion_sa" {
  count = var.create_service_account ? 1 : 0

  account_id   = "${local.bastion_name}-sa"
  display_name = "Bastion Host Service Account"
  project      = var.project_id
}

# IAM binding for OS Login
resource "google_project_iam_member" "bastion_oslogin" {
  count = var.enable_oslogin && var.create_service_account ? 1 : 0

  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = "serviceAccount:${google_service_account.bastion_sa[0].email}"
}

# Bastion Host Instance
resource "google_compute_instance" "bastion" {
  name         = local.bastion_name
  project      = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  
  tags = concat(["bastion", "allow-ssh"], var.tags)
  
  labels = merge(
    {
      purpose     = "bastion"
      environment = var.environment
    },
    var.labels
  )

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb
      type  = var.disk_type
    }
    auto_delete = var.auto_delete_disk
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {
        nat_ip       = var.static_ip
        network_tier = var.network_tier
      }
    }
  }

  service_account {
    email  = var.create_service_account ? google_service_account.bastion_sa[0].email : var.service_account_email
    scopes = var.service_account_scopes
  }

  shielded_instance_config {
    enable_secure_boot          = var.enable_shielded_vm
    enable_vtpm                 = var.enable_shielded_vm
    enable_integrity_monitoring = var.enable_shielded_vm
  }

  metadata = merge(
    {
      enable-oslogin         = var.enable_oslogin ? "TRUE" : "FALSE"
      block-project-ssh-keys = var.block_project_ssh_keys ? "TRUE" : "FALSE"
    },
    var.startup_script != "" ? { startup-script = var.startup_script } : {},
    var.metadata
  )

  scheduling {
    preemptible                 = var.preemptible
    automatic_restart           = var.preemptible ? false : var.automatic_restart
    on_host_maintenance         = var.preemptible ? "TERMINATE" : var.on_host_maintenance
    provisioning_model          = var.preemptible ? "SPOT" : "STANDARD"
    instance_termination_action = var.preemptible ? "STOP" : null
  }

  deletion_protection = var.deletion_protection

  allow_stopping_for_update = true
}

# Firewall rule for IAP SSH access
resource "google_compute_firewall" "bastion_iap_ssh" {
  count = var.create_iap_firewall_rule ? 1 : 0

  name    = "${local.bastion_name}-allow-iap-ssh"
  project = var.host_project_id != "" ? var.host_project_id : var.project_id
  network = var.network

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP's IP range
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion", "allow-ssh"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Outputs
output "instance_id" {
  value       = google_compute_instance.bastion.instance_id
  description = "The server-assigned unique identifier of the instance"
}

output "instance_name" {
  value       = google_compute_instance.bastion.name
  description = "The name of the bastion instance"
}

output "instance_self_link" {
  value       = google_compute_instance.bastion.self_link
  description = "The URI of the created resource"
}

output "internal_ip" {
  value       = google_compute_instance.bastion.network_interface[0].network_ip
  description = "The internal IP address of the bastion"
}

output "external_ip" {
  value       = var.assign_public_ip ? google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip : null
  description = "The external IP address of the bastion (if assigned)"
}

output "service_account_email" {
  value       = var.create_service_account ? google_service_account.bastion_sa[0].email : var.service_account_email
  description = "The email of the service account"
}

output "zone" {
  value       = google_compute_instance.bastion.zone
  description = "The zone of the bastion instance"
}

output "ssh_command" {
  value       = var.enable_oslogin ? "gcloud compute ssh ${google_compute_instance.bastion.name} --zone=${var.zone} --tunnel-through-iap" : "gcloud compute ssh ${google_compute_instance.bastion.name} --zone=${var.zone}"
  description = "SSH command to connect to bastion"
}
