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

resource "google_compute_router" "router" {
  name    = var.router_name
  region  = var.region
  network = var.network_id
  project = var.project_id

  bgp {
    asn = var.bgp_asn
  }
}

output "router_id" {
  value       = google_compute_router.router.id
  description = "Router ID"
}

output "router_name" {
  value       = google_compute_router.router.name
  description = "Router name"
}
