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
  nat_instance_name = var.name != "" ? var.name : "nat-gateway-${var.zone}"
  startup_script    = var.custom_startup_script != "" ? var.custom_startup_script : <<-EOF
    #!/bin/bash
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    
    # Make IP forwarding persistent
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
    
    # Install iptables-persistent if available
    if command -v apt-get &> /dev/null; then
      apt-get update
      echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
      echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
      apt-get install -y iptables-persistent
    fi
  EOF
}

# Service Account
resource "google_service_account" "nat_sa" {
  count = var.create_service_account ? 1 : 0

  account_id   = "${local.nat_instance_name}-sa"
  display_name = "NAT Instance Service Account"
  project      = var.project_id
}

# External IP for NAT Instance
resource "google_compute_address" "nat_ip" {
  count = var.create_static_ip ? 1 : 0

  name         = "${local.nat_instance_name}-ip"
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = var.network_tier
}

# NAT Instance
resource "google_compute_instance" "nat_instance" {
  name         = local.nat_instance_name
  project      = var.project_id
  zone         = var.zone
  machine_type = var.machine_type

  tags = concat(["nat-instance", "allow-health-checks"], var.tags)

  labels = merge(
    {
      purpose     = "nat-gateway"
      environment = var.environment
    },
    var.labels
  )

  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb
      type  = var.disk_type
    }
    auto_delete = true
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
      nat_ip       = var.create_static_ip ? google_compute_address.nat_ip[0].address : null
      network_tier = var.network_tier
    }
  }

  service_account {
    email  = var.create_service_account ? google_service_account.nat_sa[0].email : var.service_account_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = var.enable_shielded_vm
    enable_vtpm                 = var.enable_shielded_vm
    enable_integrity_monitoring = var.enable_shielded_vm
  }

  metadata = merge(
    {
      startup-script = local.startup_script
    },
    var.metadata
  )

  scheduling {
    preemptible                 = var.preemptible
    automatic_restart           = var.preemptible ? false : true
    on_host_maintenance         = var.preemptible ? "TERMINATE" : "MIGRATE"
    provisioning_model          = var.preemptible ? "SPOT" : "STANDARD"
  }

  allow_stopping_for_update = true
}

# Route for NAT
resource "google_compute_route" "nat_route" {
  for_each = toset(var.destination_ranges)

  name                   = "${local.nat_instance_name}-route-${replace(each.value, "/", "-")}"
  project                = var.project_id
  network                = var.network
  dest_range             = each.value
  next_hop_instance      = google_compute_instance.nat_instance.id
  next_hop_instance_zone = var.zone
  priority               = var.route_priority
  tags                   = var.route_tags
}

# Outputs
output "instance_id" {
  value       = google_compute_instance.nat_instance.instance_id
  description = "The instance ID"
}

output "instance_name" {
  value       = google_compute_instance.nat_instance.name
  description = "The instance name"
}

output "instance_self_link" {
  value       = google_compute_instance.nat_instance.self_link
  description = "The self_link of the instance"
}

output "internal_ip" {
  value       = google_compute_instance.nat_instance.network_interface[0].network_ip
  description = "The internal IP"
}

output "external_ip" {
  value       = google_compute_instance.nat_instance.network_interface[0].access_config[0].nat_ip
  description = "The external IP"
}

output "route_ids" {
  value       = { for k, v in google_compute_route.nat_route : k => v.id }
  description = "Map of route IDs"
}

output "service_account_email" {
  value       = var.create_service_account ? google_service_account.nat_sa[0].email : var.service_account_email
  description = "The service account email"
}
