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

# Global External IP Addresses
resource "google_compute_global_address" "global_addresses" {
  for_each = var.global_addresses

  name          = each.key
  project       = var.project_id
  description   = lookup(each.value, "description", null)
  address_type  = lookup(each.value, "address_type", "EXTERNAL")
  ip_version    = lookup(each.value, "ip_version", "IPV4")
  prefix_length = lookup(each.value, "prefix_length", null)
  address       = lookup(each.value, "address", null)
  purpose       = lookup(each.value, "purpose", null)
  network       = lookup(each.value, "network", null)
  labels        = lookup(each.value, "labels", {})
}

# Regional External IP Addresses
resource "google_compute_address" "external_addresses" {
  for_each = var.external_addresses

  name                  = each.key
  project               = var.project_id
  region                = lookup(each.value, "region", var.region)
  description           = lookup(each.value, "description", null)
  address_type          = "EXTERNAL"
  network_tier          = lookup(each.value, "network_tier", "PREMIUM")
  address               = lookup(each.value, "address", null)
  prefix_length         = lookup(each.value, "prefix_length", null)
  labels                = lookup(each.value, "labels", {})
}

# Regional Internal IP Addresses
resource "google_compute_address" "internal_addresses" {
  for_each = var.internal_addresses

  name                  = each.key
  project               = var.project_id
  region                = lookup(each.value, "region", var.region)
  description           = lookup(each.value, "description", null)
  address_type          = "INTERNAL"
  address               = lookup(each.value, "address", null)
  subnetwork            = each.value.subnetwork
  purpose               = lookup(each.value, "purpose", "GCE_ENDPOINT")
  network_tier          = lookup(each.value, "network_tier", null)
  labels                = lookup(each.value, "labels", {})
}

# Private Service Connect Addresses
resource "google_compute_global_address" "psc_addresses" {
  for_each = var.psc_addresses

  name          = each.key
  project       = var.project_id
  description   = lookup(each.value, "description", null)
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = lookup(each.value, "prefix_length", 16)
  network       = each.value.network
  labels        = lookup(each.value, "labels", {})
}

# Outputs
output "global_addresses" {
  value = {
    for k, v in google_compute_global_address.global_addresses : k => {
      id         = v.id
      address    = v.address
      self_link  = v.self_link
    }
  }
  description = "Global IP addresses"
}

output "external_addresses" {
  value = {
    for k, v in google_compute_address.external_addresses : k => {
      id         = v.id
      address    = v.address
      self_link  = v.self_link
      region     = v.region
    }
  }
  description = "Regional external IP addresses"
}

output "internal_addresses" {
  value = {
    for k, v in google_compute_address.internal_addresses : k => {
      id         = v.id
      address    = v.address
      self_link  = v.self_link
      region     = v.region
    }
  }
  description = "Regional internal IP addresses"
}

output "psc_addresses" {
  value = {
    for k, v in google_compute_global_address.psc_addresses : k => {
      id         = v.id
      address    = v.address
      self_link  = v.self_link
    }
  }
  description = "Private Service Connect addresses"
}
