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

resource "google_redis_instance" "instances" {
  for_each = var.redis_instances

  name               = each.value.name
  project            = var.project_id
  region             = each.value.region != null ? each.value.region : var.region
  tier               = each.value.tier
  memory_size_gb     = each.value.memory_size_gb
  redis_version      = each.value.redis_version
  display_name       = each.value.display_name
  authorized_network = each.value.authorized_network
  connect_mode       = each.value.connect_mode
  auth_enabled       = each.value.auth_enabled
  transit_encryption_mode = each.value.transit_encryption_mode
  replica_count      = each.value.replica_count
  read_replicas_mode = each.value.read_replicas_mode
  location_id        = each.value.location_id
  alternative_location_id = each.value.alternative_location_id
  reserved_ip_range  = each.value.reserved_ip_range
  customer_managed_key = each.value.customer_managed_key

  redis_configs = each.value.redis_configs

  dynamic "maintenance_policy" {
    for_each = each.value.maintenance_policy != null ? [each.value.maintenance_policy] : []
    content {
      weekly_maintenance_window {
        day = maintenance_policy.value.day
        start_time {
          hours   = maintenance_policy.value.start_time_hours
          minutes = maintenance_policy.value.start_time_minutes
        }
      }
    }
  }

  dynamic "persistence_config" {
    for_each = each.value.persistence_config != null ? [each.value.persistence_config] : []
    content {
      persistence_mode    = persistence_config.value.persistence_mode
      rdb_snapshot_period = persistence_config.value.rdb_snapshot_period
    }
  }

  labels = each.value.labels
}

output "redis_instances" {
  value = {
    for k, v in google_redis_instance.instances : k => {
      id              = v.id
      name            = v.name
      host            = v.host
      port            = v.port
      current_location_id = v.current_location_id
      read_endpoint   = v.read_endpoint
      read_endpoint_port = v.read_endpoint_port
    }
  }
  description = "Redis instance details"
}

output "redis_hosts" {
  value       = { for k, v in google_redis_instance.instances : k => v.host }
  description = "Redis instance hosts"
}

output "redis_auth_strings" {
  value       = { for k, v in google_redis_instance.instances : k => v.auth_string }
  description = "Redis instance auth strings"
  sensitive   = true
}
