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

# Global Address for Private Service Access
resource "google_compute_global_address" "private_service_addresses" {
  for_each = var.private_service_addresses

  name          = each.value.name
  project       = var.project_id
  purpose       = each.value.purpose
  address_type  = each.value.address_type
  prefix_length = each.value.prefix_length
  address       = each.value.address
  network       = each.value.network
  description   = each.value.description
  labels        = each.value.labels
}

# Private Service Connection
resource "google_service_networking_connection" "private_vpc_connections" {
  for_each = var.private_vpc_connections

  network                 = each.value.network
  service                 = each.value.service
  reserved_peering_ranges = each.value.reserved_peering_ranges
  deletion_policy         = each.value.deletion_policy

  depends_on = [google_compute_global_address.private_service_addresses]
}

# Peered DNS Domains for Private Service Access
resource "google_service_networking_peered_dns_domain" "peered_dns_domains" {
  for_each = var.peered_dns_domains

  project    = var.project_id
  name       = each.value.name
  network    = each.value.network
  dns_suffix = each.value.dns_suffix
  service    = each.value.service

  depends_on = [google_service_networking_connection.private_vpc_connections]
}

# VPC Access Connector (for Serverless VPC Access)
resource "google_vpc_access_connector" "connectors" {
  for_each = var.vpc_access_connectors

  name           = each.value.name
  project        = var.project_id
  region         = each.value.region
  network        = each.value.network
  ip_cidr_range  = each.value.ip_cidr_range
  machine_type   = each.value.machine_type
  min_instances  = each.value.min_instances
  max_instances  = each.value.max_instances
  min_throughput = each.value.min_throughput
  max_throughput = each.value.max_throughput

  dynamic "subnet" {
    for_each = each.value.subnet_name != null ? [1] : []
    content {
      name       = each.value.subnet_name
      project_id = each.value.subnet_project_id
    }
  }
}

output "private_service_address_ids" {
  value       = { for k, v in google_compute_global_address.private_service_addresses : k => v.id }
  description = "Private service address IDs"
}

output "private_service_addresses" {
  value       = { for k, v in google_compute_global_address.private_service_addresses : k => v.address }
  description = "Private service addresses"
}

output "private_service_address_self_links" {
  value       = { for k, v in google_compute_global_address.private_service_addresses : k => v.self_link }
  description = "Private service address self links"
}

output "private_vpc_connection_peerings" {
  value       = { for k, v in google_service_networking_connection.private_vpc_connections : k => v.peering }
  description = "Private VPC connection peering names"
}

output "peered_dns_domain_ids" {
  value       = { for k, v in google_service_networking_peered_dns_domain.peered_dns_domains : k => v.id }
  description = "Peered DNS domain IDs"
}

output "vpc_access_connector_ids" {
  value       = { for k, v in google_vpc_access_connector.connectors : k => v.id }
  description = "VPC Access Connector IDs"
}

output "vpc_access_connector_self_links" {
  value       = { for k, v in google_vpc_access_connector.connectors : k => v.self_link }
  description = "VPC Access Connector self links"
}

output "vpc_access_connector_states" {
  value       = { for k, v in google_vpc_access_connector.connectors : k => v.state }
  description = "VPC Access Connector states"
}
