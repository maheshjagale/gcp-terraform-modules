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

# Health Check
resource "google_compute_health_check" "health_check" {
  name                = "${var.name}-health-check"
  project             = var.project_id
  check_interval_sec  = var.health_check.check_interval_sec
  timeout_sec         = var.health_check.timeout_sec
  healthy_threshold   = var.health_check.healthy_threshold
  unhealthy_threshold = var.health_check.unhealthy_threshold

  dynamic "tcp_health_check" {
    for_each = var.health_check.type == "TCP" ? [1] : []
    content {
      port               = var.health_check.port
      port_specification = lookup(var.health_check, "port_specification", "USE_FIXED_PORT")
    }
  }

  dynamic "http_health_check" {
    for_each = var.health_check.type == "HTTP" ? [1] : []
    content {
      port               = var.health_check.port
      port_specification = lookup(var.health_check, "port_specification", "USE_FIXED_PORT")
      request_path       = lookup(var.health_check, "request_path", "/")
      host               = lookup(var.health_check, "host", null)
    }
  }

  dynamic "https_health_check" {
    for_each = var.health_check.type == "HTTPS" ? [1] : []
    content {
      port               = var.health_check.port
      port_specification = lookup(var.health_check, "port_specification", "USE_FIXED_PORT")
      request_path       = lookup(var.health_check, "request_path", "/")
      host               = lookup(var.health_check, "host", null)
    }
  }

  log_config {
    enable = var.health_check_logging
  }
}

# Regional Backend Service
resource "google_compute_region_backend_service" "backend_service" {
  name                            = "${var.name}-backend"
  project                         = var.project_id
  region                          = var.region
  protocol                        = var.protocol
  load_balancing_scheme           = "INTERNAL"
  network                         = var.network
  session_affinity                = var.session_affinity
  timeout_sec                     = var.timeout_sec
  connection_draining_timeout_sec = var.connection_draining_timeout_sec
  health_checks                   = [google_compute_health_check.health_check.id]

  dynamic "backend" {
    for_each = var.backends
    content {
      group          = backend.value.group
      balancing_mode = lookup(backend.value, "balancing_mode", "CONNECTION")
      failover       = lookup(backend.value, "failover", false)
    }
  }

  dynamic "failover_policy" {
    for_each = var.failover_policy != null ? [var.failover_policy] : []
    content {
      disable_connection_drain_on_failover = lookup(failover_policy.value, "disable_connection_drain_on_failover", false)
      drop_traffic_if_unhealthy            = lookup(failover_policy.value, "drop_traffic_if_unhealthy", false)
      failover_ratio                       = lookup(failover_policy.value, "failover_ratio", 0)
    }
  }

  dynamic "log_config" {
    for_each = var.log_config != null ? [var.log_config] : []
    content {
      enable      = lookup(log_config.value, "enable", true)
      sample_rate = lookup(log_config.value, "sample_rate", 1.0)
    }
  }
}

# Forwarding Rule
resource "google_compute_forwarding_rule" "forwarding_rule" {
  name                  = "${var.name}-fwd-rule"
  project               = var.project_id
  region                = var.region
  network               = var.network
  subnetwork            = var.subnetwork
  ip_address            = var.ip_address
  ip_protocol           = var.ip_protocol
  ports                 = var.all_ports ? null : var.ports
  all_ports             = var.all_ports
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.backend_service.id
  allow_global_access   = var.allow_global_access
  service_label         = var.service_label
  labels                = var.labels
}

# Outputs
output "forwarding_rule_id" {
  value       = google_compute_forwarding_rule.forwarding_rule.id
  description = "The ID of the forwarding rule"
}

output "forwarding_rule_ip" {
  value       = google_compute_forwarding_rule.forwarding_rule.ip_address
  description = "The IP address of the forwarding rule"
}

output "forwarding_rule_self_link" {
  value       = google_compute_forwarding_rule.forwarding_rule.self_link
  description = "The self_link of the forwarding rule"
}

output "backend_service_id" {
  value       = google_compute_region_backend_service.backend_service.id
  description = "The ID of the backend service"
}

output "backend_service_self_link" {
  value       = google_compute_region_backend_service.backend_service.self_link
  description = "The self_link of the backend service"
}

output "health_check_id" {
  value       = google_compute_health_check.health_check.id
  description = "The ID of the health check"
}

output "service_name" {
  value       = var.service_label != null ? "${var.service_label}.${var.region}.internal" : null
  description = "The DNS name for the service"
}
