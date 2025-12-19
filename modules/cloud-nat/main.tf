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

# Cloud Router (if not provided)
resource "google_compute_router" "router" {
  count = var.create_router ? 1 : 0

  name    = var.router_name != "" ? var.router_name : "${var.name}-router"
  project = var.project_id
  region  = var.region
  network = var.network

  bgp {
    asn                = var.router_asn
    advertise_mode     = var.router_advertise_mode
    advertised_groups  = var.router_advertise_mode == "CUSTOM" ? var.router_advertised_groups : null
    keepalive_interval = var.router_keepalive_interval

    dynamic "advertised_ip_ranges" {
      for_each = var.router_advertise_mode == "CUSTOM" ? var.router_advertised_ip_ranges : []
      content {
        range       = advertised_ip_ranges.value.range
        description = lookup(advertised_ip_ranges.value, "description", null)
      }
    }
  }
}

# Cloud NAT
resource "google_compute_router_nat" "nat" {
  name    = var.name
  project = var.project_id
  region  = var.region
  router  = var.create_router ? google_compute_router.router[0].name : var.router_name

  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  nat_ips = var.nat_ip_allocate_option == "MANUAL_ONLY" ? var.nat_ips : null

  # Subnetwork configuration
  dynamic "subnetwork" {
    for_each = var.source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS" ? var.subnetworks : []
    content {
      name                    = subnetwork.value.name
      source_ip_ranges_to_nat = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = lookup(subnetwork.value, "secondary_ip_range_names", null)
    }
  }

  # Port allocation
  min_ports_per_vm                    = var.min_ports_per_vm
  max_ports_per_vm                    = var.max_ports_per_vm
  enable_dynamic_port_allocation      = var.enable_dynamic_port_allocation
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping

  # Timeouts
  udp_idle_timeout_sec             = var.udp_idle_timeout_sec
  icmp_idle_timeout_sec            = var.icmp_idle_timeout_sec
  tcp_established_idle_timeout_sec = var.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec  = var.tcp_transitory_idle_timeout_sec
  tcp_time_wait_timeout_sec        = var.tcp_time_wait_timeout_sec

  # Logging
  log_config {
    enable = var.log_config_enable
    filter = var.log_config_filter
  }

  # Rules
  dynamic "rules" {
    for_each = var.nat_rules
    content {
      rule_number = rules.value.rule_number
      description = lookup(rules.value, "description", null)
      match       = rules.value.match

      action {
        source_nat_active_ips = lookup(rules.value.action, "source_nat_active_ips", null)
        source_nat_drain_ips  = lookup(rules.value.action, "source_nat_drain_ips", null)
      }
    }
  }
}

# Outputs
output "router_id" {
  value       = var.create_router ? google_compute_router.router[0].id : null
  description = "The ID of the Cloud Router"
}

output "router_name" {
  value       = var.create_router ? google_compute_router.router[0].name : var.router_name
  description = "The name of the Cloud Router"
}

output "router_self_link" {
  value       = var.create_router ? google_compute_router.router[0].self_link : null
  description = "The self_link of the Cloud Router"
}

output "nat_id" {
  value       = google_compute_router_nat.nat.id
  description = "The ID of the Cloud NAT"
}

output "nat_name" {
  value       = google_compute_router_nat.nat.name
  description = "The name of the Cloud NAT"
}

output "nat_ips_used" {
  value       = google_compute_router_nat.nat.nat_ips
  description = "The NAT IPs used"
}

output "region" {
  value       = var.region
  description = "The region of the Cloud NAT"
}
