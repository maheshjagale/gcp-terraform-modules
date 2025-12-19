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

# DNS Managed Zones
resource "google_dns_managed_zone" "zones" {
  for_each = var.dns_zones

  name          = each.value.name
  project       = var.project_id
  dns_name      = each.value.dns_name
  description   = each.value.description
  visibility    = each.value.visibility
  force_destroy = each.value.force_destroy
  labels        = each.value.labels

  dynamic "private_visibility_config" {
    for_each = each.value.visibility == "private" ? [1] : []
    content {
      dynamic "networks" {
        for_each = each.value.private_visibility_networks != null ? each.value.private_visibility_networks : []
        content {
          network_url = networks.value
        }
      }

      dynamic "gke_clusters" {
        for_each = each.value.private_visibility_gke_clusters != null ? each.value.private_visibility_gke_clusters : []
        content {
          gke_cluster_name = gke_clusters.value
        }
      }
    }
  }

  dynamic "forwarding_config" {
    for_each = each.value.forwarding_targets != null ? [1] : []
    content {
      dynamic "target_name_servers" {
        for_each = each.value.forwarding_targets
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = target_name_servers.value.forwarding_path
        }
      }
    }
  }

  dynamic "peering_config" {
    for_each = each.value.peering_network != null ? [1] : []
    content {
      target_network {
        network_url = each.value.peering_network
      }
    }
  }

  dynamic "dnssec_config" {
    for_each = each.value.dnssec_config != null ? [each.value.dnssec_config] : []
    content {
      state         = dnssec_config.value.state
      kind          = dnssec_config.value.kind
      non_existence = dnssec_config.value.non_existence

      dynamic "default_key_specs" {
        for_each = dnssec_config.value.default_key_specs != null ? dnssec_config.value.default_key_specs : []
        content {
          algorithm  = default_key_specs.value.algorithm
          key_length = default_key_specs.value.key_length
          key_type   = default_key_specs.value.key_type
          kind       = default_key_specs.value.kind
        }
      }
    }
  }

  dynamic "cloud_logging_config" {
    for_each = each.value.enable_logging ? [1] : []
    content {
      enable_logging = each.value.enable_logging
    }
  }
}

# DNS Record Sets
resource "google_dns_record_set" "records" {
  for_each = var.dns_records

  name         = each.value.name
  project      = var.project_id
  managed_zone = each.value.managed_zone
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas

  dynamic "routing_policy" {
    for_each = each.value.routing_policy != null ? [each.value.routing_policy] : []
    content {
      dynamic "geo" {
        for_each = routing_policy.value.geo != null ? routing_policy.value.geo : []
        content {
          location = geo.value.location
          rrdatas  = geo.value.rrdatas
        }
      }

      dynamic "wrr" {
        for_each = routing_policy.value.wrr != null ? routing_policy.value.wrr : []
        content {
          weight  = wrr.value.weight
          rrdatas = wrr.value.rrdatas
        }
      }
    }
  }

  depends_on = [google_dns_managed_zone.zones]
}

output "zone_ids" {
  value       = { for k, v in google_dns_managed_zone.zones : k => v.id }
  description = "DNS zone IDs"
}

output "zone_name_servers" {
  value       = { for k, v in google_dns_managed_zone.zones : k => v.name_servers }
  description = "DNS zone name servers"
}

output "zone_dns_names" {
  value       = { for k, v in google_dns_managed_zone.zones : k => v.dns_name }
  description = "DNS zone DNS names"
}

output "zone_managed_zone_ids" {
  value       = { for k, v in google_dns_managed_zone.zones : k => v.managed_zone_id }
  description = "Unique identifier for the zone"
}

output "record_ids" {
  value       = { for k, v in google_dns_record_set.records : k => v.id }
  description = "DNS record set IDs"
}
