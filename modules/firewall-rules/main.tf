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

# Firewall Rules
resource "google_compute_firewall" "rules" {
  for_each = var.firewall_rules

  name        = each.key
  project     = var.project_id
  network     = var.network
  description = lookup(each.value, "description", null)

  direction               = lookup(each.value, "direction", "INGRESS")
  priority                = lookup(each.value, "priority", 1000)
  disabled                = lookup(each.value, "disabled", false)
  destination_ranges      = lookup(each.value, "direction", "INGRESS") == "EGRESS" ? lookup(each.value, "destination_ranges", null) : null
  source_ranges           = lookup(each.value, "direction", "INGRESS") == "INGRESS" ? lookup(each.value, "source_ranges", null) : null
  source_tags             = lookup(each.value, "direction", "INGRESS") == "INGRESS" ? lookup(each.value, "source_tags", null) : null
  source_service_accounts = lookup(each.value, "direction", "INGRESS") == "INGRESS" ? lookup(each.value, "source_service_accounts", null) : null
  target_tags             = lookup(each.value, "target_tags", null)
  target_service_accounts = lookup(each.value, "target_service_accounts", null)

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }

  dynamic "log_config" {
    for_each = lookup(each.value, "log_config", null) != null ? [each.value.log_config] : []
    content {
      metadata = log_config.value.metadata
    }
  }
}

# Common Firewall Rules (optional)
resource "google_compute_firewall" "allow_internal" {
  count = var.create_common_rules ? 1 : 0

  name        = "${var.network_name}-allow-internal"
  project     = var.project_id
  network     = var.network
  description = "Allow internal traffic within the VPC"

  direction = "INGRESS"
  priority  = 65534

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = var.internal_ranges

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_iap_ssh" {
  count = var.create_common_rules && var.allow_iap_ssh ? 1 : 0

  name        = "${var.network_name}-allow-iap-ssh"
  project     = var.project_id
  network     = var.network
  description = "Allow SSH access via IAP"

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-ssh"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_iap_rdp" {
  count = var.create_common_rules && var.allow_iap_rdp ? 1 : 0

  name        = "${var.network_name}-allow-iap-rdp"
  project     = var.project_id
  network     = var.network
  description = "Allow RDP access via IAP"

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-rdp"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_health_checks" {
  count = var.create_common_rules && var.allow_health_checks ? 1 : 0

  name        = "${var.network_name}-allow-health-checks"
  project     = var.project_id
  network     = var.network
  description = "Allow health check probes"

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
  target_tags   = ["allow-health-checks"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "deny_all_egress" {
  count = var.create_common_rules && var.deny_all_egress ? 1 : 0

  name        = "${var.network_name}-deny-all-egress"
  project     = var.project_id
  network     = var.network
  description = "Deny all egress traffic"

  direction = "EGRESS"
  priority  = 65535

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Outputs
output "firewall_rule_ids" {
  value       = { for k, v in google_compute_firewall.rules : k => v.id }
  description = "Map of firewall rule IDs"
}

output "firewall_rule_self_links" {
  value       = { for k, v in google_compute_firewall.rules : k => v.self_link }
  description = "Map of firewall rule self_links"
}

output "firewall_rule_names" {
  value       = { for k, v in google_compute_firewall.rules : k => v.name }
  description = "Map of firewall rule names"
}

output "common_rule_ids" {
  value = {
    allow_internal      = var.create_common_rules ? try(google_compute_firewall.allow_internal[0].id, null) : null
    allow_iap_ssh       = var.create_common_rules && var.allow_iap_ssh ? try(google_compute_firewall.allow_iap_ssh[0].id, null) : null
    allow_iap_rdp       = var.create_common_rules && var.allow_iap_rdp ? try(google_compute_firewall.allow_iap_rdp[0].id, null) : null
    allow_health_checks = var.create_common_rules && var.allow_health_checks ? try(google_compute_firewall.allow_health_checks[0].id, null) : null
    deny_all_egress     = var.create_common_rules && var.deny_all_egress ? try(google_compute_firewall.deny_all_egress[0].id, null) : null
  }
  description = "IDs of common firewall rules"
}
