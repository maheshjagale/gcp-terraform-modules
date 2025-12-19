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

# VLAN Attachments for Dedicated Interconnect
resource "google_compute_interconnect_attachment" "attachments" {
  for_each = var.interconnect_attachments

  name                     = each.value.name
  project                  = var.project_id
  region                   = each.value.region
  router                   = each.value.router
  type                     = each.value.type
  interconnect             = each.value.interconnect
  description              = each.value.description
  mtu                      = each.value.mtu
  bandwidth                = each.value.bandwidth
  edge_availability_domain = each.value.edge_availability_domain
  admin_enabled            = each.value.admin_enabled
  vlan_tag8021q            = each.value.vlan_tag8021q
  candidate_subnets        = each.value.candidate_subnets
  encryption               = each.value.encryption
  ipsec_internal_addresses = each.value.ipsec_internal_addresses
  stack_type               = each.value.stack_type
}

# Router Interface for Interconnect Attachment
resource "google_compute_router_interface" "interconnect_interfaces" {
  for_each = var.interconnect_attachments

  name                    = "${each.value.name}-interface"
  project                 = var.project_id
  region                  = each.value.region
  router                  = each.value.router
  ip_range                = each.value.router_interface_ip_range
  interconnect_attachment = google_compute_interconnect_attachment.attachments[each.key].self_link
}

# BGP Peer for Interconnect
resource "google_compute_router_peer" "interconnect_peers" {
  for_each = { for k, v in var.interconnect_attachments : k => v if v.create_bgp_peer }

  name                      = "${each.value.name}-peer"
  project                   = var.project_id
  region                    = each.value.region
  router                    = each.value.router
  interface                 = google_compute_router_interface.interconnect_interfaces[each.key].name
  peer_asn                  = each.value.bgp_peer_asn
  peer_ip_address           = each.value.bgp_peer_ip_address
  advertised_route_priority = each.value.bgp_advertised_route_priority
  advertise_mode            = each.value.bgp_advertise_mode
  advertised_groups         = each.value.bgp_advertised_groups

  dynamic "advertised_ip_ranges" {
    for_each = each.value.bgp_advertised_ip_ranges != null ? each.value.bgp_advertised_ip_ranges : []
    content {
      range       = advertised_ip_ranges.value.range
      description = advertised_ip_ranges.value.description
    }
  }

  dynamic "bfd" {
    for_each = each.value.bfd_enabled ? [1] : []
    content {
      session_initialization_mode = each.value.bfd_session_initialization_mode
      min_transmit_interval       = each.value.bfd_min_transmit_interval
      min_receive_interval        = each.value.bfd_min_receive_interval
      multiplier                  = each.value.bfd_multiplier
    }
  }
}

output "attachment_ids" {
  value       = { for k, v in google_compute_interconnect_attachment.attachments : k => v.id }
  description = "Interconnect attachment IDs"
}

output "attachment_self_links" {
  value       = { for k, v in google_compute_interconnect_attachment.attachments : k => v.self_link }
  description = "Interconnect attachment self links"
}

output "attachment_pairing_keys" {
  value       = { for k, v in google_compute_interconnect_attachment.attachments : k => v.pairing_key }
  description = "Pairing keys for partner interconnect"
  sensitive   = true
}

output "attachment_cloud_router_ip_addresses" {
  value       = { for k, v in google_compute_interconnect_attachment.attachments : k => v.cloud_router_ip_address }
  description = "Cloud router IP addresses"
}

output "attachment_customer_router_ip_addresses" {
  value       = { for k, v in google_compute_interconnect_attachment.attachments : k => v.customer_router_ip_address }
  description = "Customer router IP addresses"
}

output "attachment_states" {
  value       = { for k, v in google_compute_interconnect_attachment.attachments : k => v.state }
  description = "Interconnect attachment states"
}

output "interface_ids" {
  value       = { for k, v in google_compute_router_interface.interconnect_interfaces : k => v.id }
  description = "Router interface IDs"
}

output "bgp_peer_ids" {
  value       = { for k, v in google_compute_router_peer.interconnect_peers : k => v.id }
  description = "BGP peer IDs"
}
