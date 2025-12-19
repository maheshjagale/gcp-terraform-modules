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

# Subnetworks
resource "google_compute_subnetwork" "subnets" {
  for_each = var.subnets

  name                       = each.value.name
  project                    = var.project_id
  region                     = each.value.region
  network                    = each.value.network
  ip_cidr_range              = each.value.ip_cidr_range
  purpose                    = each.value.purpose
  role                       = each.value.role
  private_ip_google_access   = each.value.private_ip_google_access
  private_ipv6_google_access = each.value.private_ipv6_google_access
  stack_type                 = each.value.stack_type
  ipv6_access_type           = each.value.ipv6_access_type
  description                = each.value.description

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges != null ? each.value.secondary_ip_ranges : []
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_config != null ? [each.value.log_config] : []
    content {
      aggregation_interval = log_config.value.aggregation_interval
      flow_sampling        = log_config.value.flow_sampling
      metadata             = log_config.value.metadata
      metadata_fields      = log_config.value.metadata_fields
      filter_expr          = log_config.value.filter_expr
    }
  }
}

output "subnet_ids" {
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.id }
  description = "Subnet IDs"
}

output "subnet_self_links" {
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.self_link }
  description = "Subnet self links"
}

output "subnet_names" {
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.name }
  description = "Subnet names"
}

output "subnet_ip_cidr_ranges" {
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.ip_cidr_range }
  description = "Subnet primary IP CIDR ranges"
}

output "subnet_regions" {
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.region }
  description = "Subnet regions"
}

output "subnet_secondary_ranges" {
  value = {
    for k, v in google_compute_subnetwork.subnets : k => [
      for s in v.secondary_ip_range : {
        range_name    = s.range_name
        ip_cidr_range = s.ip_cidr_range
      }
    ]
  }
  description = "Subnet secondary IP ranges"
}

output "subnet_gateway_addresses" {
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.gateway_address }
  description = "Subnet gateway addresses"
}
