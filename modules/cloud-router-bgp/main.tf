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

# Cloud Router
resource "google_compute_router" "routers" {
  for_each = var.cloud_routers

  name        = each.value.name
  project     = var.project_id
  region      = each.value.region
  network     = each.value.network
  description = each.value.description
  encrypted_interconnect_router = each.value.encrypted_interconnect_router

  bgp {
    asn                = each.value.bgp_asn
    advertise_mode     = each.value.bgp_advertise_mode
    advertised_groups  = each.value.bgp_advertised_groups
    keepalive_interval = each.value.bgp_keepalive_interval

    dynamic "advertised_ip_ranges" {
      for_each = each.value.bgp_advertised_ip_ranges != null ? each.value.bgp_advertised_ip_ranges : []
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
  }
}

# Router Interface
resource "google_compute_router_interface" "interfaces" {
  for_each = var.router_interfaces

  name                    = each.value.name
  project                 = var.project_id
  region                  = each.value.region
  router                  = each.value.router
  ip_range                = each.value.ip_range
  vpn_tunnel              = each.value.vpn_tunnel
  interconnect_attachment = each.value.interconnect_attachment
  subnetwork              = each.value.subnetwork
  private_ip_address      = each.value.private_ip_address
  redundant_interface     = each.value.redundant_interface

  depends_on = [google_compute_router.routers]
}

# BGP Peer
resource "google_compute_router_peer" "peers" {
  for_each = var.bgp_peers

  name                      = each.value.name
  project                   = var.project_id
  region                    = each.value.region
  router                    = each.value.router
  interface                 = each.value.interface
  peer_asn                  = each.value.peer_asn
  peer_ip_address           = each.value.peer_ip_address
  ip_address                = each.value.ip_address
  advertised_route_priority = each.value.advertised_route_priority
  advertise_mode            = each.value.advertise_mode
  advertised_groups         = each.value.advertised_groups
  enable                    = each.value.enable
  enable_ipv6               = each.value.enable_ipv6
  ipv6_nexthop_address      = each.value.ipv6_nexthop_address
  peer_ipv6_nexthop_address = each.value.peer_ipv6_nexthop_address

  dynamic "advertised_ip_ranges" {
    for_each = each.value.advertised_ip_ranges != null ? each.value.advertised_ip_ranges : []
    content {
      range       = advertised_ip_ranges.value.range
      description = advertised_ip_ranges.value.description
    }
  }

  dynamic "bfd" {
    for_each = each.value.bfd != null ? [each.value.bfd] : []
    content {
      session_initialization_mode = bfd.value.session_initialization_mode
      min_transmit_interval       = bfd.value.min_transmit_interval
      min_receive_interval        = bfd.value.min_receive_interval
      multiplier                  = bfd.value.multiplier
    }
  }

  depends_on = [google_compute_router_interface.interfaces]
}

output "router_ids" {
  value       = { for k, v in google_compute_router.routers : k => v.id }
  description = "Cloud Router IDs"
}

output "router_self_links" {
  value       = { for k, v in google_compute_router.routers : k => v.self_link }
  description = "Cloud Router self links"
}

output "router_names" {
  value       = { for k, v in google_compute_router.routers : k => v.name }
  description = "Cloud Router names"
}

output "interface_ids" {
  value       = { for k, v in google_compute_router_interface.interfaces : k => v.id }
  description = "Router interface IDs"
}

output "bgp_peer_ids" {
  value       = { for k, v in google_compute_router_peer.peers : k => v.id }
  description = "BGP peer IDs"
}

output "bgp_peer_ip_addresses" {
  value       = { for k, v in google_compute_router_peer.peers : k => v.ip_address }
  description = "BGP peer IP addresses"
}
