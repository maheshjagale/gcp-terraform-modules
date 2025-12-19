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

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode

  labels = var.labels
}

resource "google_compute_subnetwork" "subnets" {
  for_each = {
    for subnet in var.subnets :
    subnet.name => subnet
  }

  name          = each.value.name
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = google_compute_network.vpc.id

  enable_flow_logs        = var.enable_flow_logs
  private_ip_google_access = true

  labels = var.labels
}

output "network_id" {
  value       = google_compute_network.vpc.id
  description = "Network ID"
}

output "network_name" {
  value       = google_compute_network.vpc.name
  description = "Network name"
}

output "subnets" {
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.id }
  description = "Subnet IDs"
}
