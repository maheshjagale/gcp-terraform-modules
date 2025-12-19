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
}

# VPC Network Peering
resource "google_compute_network_peering" "peerings" {
  for_each = var.network_peerings

  name                                = each.value.name
  network                             = each.value.network
  peer_network                        = each.value.peer_network
  export_custom_routes                = each.value.export_custom_routes
  import_custom_routes                = each.value.import_custom_routes
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
  stack_type                          = each.value.stack_type
}

# Optional: Peering routes configuration
resource "google_compute_network_peering_routes_config" "peering_routes" {
  for_each = { for k, v in var.network_peerings : k => v if v.configure_routes }

  project = var.project_id
  peering = google_compute_network_peering.peerings[each.key].name
  network = each.value.network_name

  import_custom_routes = each.value.import_custom_routes
  export_custom_routes = each.value.export_custom_routes
}

output "peering_ids" {
  value       = { for k, v in google_compute_network_peering.peerings : k => v.id }
  description = "Network peering IDs"
}

output "peering_names" {
  value       = { for k, v in google_compute_network_peering.peerings : k => v.name }
  description = "Network peering names"
}

output "peering_states" {
  value       = { for k, v in google_compute_network_peering.peerings : k => v.state }
  description = "Network peering states"
}

output "peering_state_details" {
  value       = { for k, v in google_compute_network_peering.peerings : k => v.state_details }
  description = "Network peering state details"
}
