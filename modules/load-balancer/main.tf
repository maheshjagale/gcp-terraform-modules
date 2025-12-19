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

# External IP Address
resource "google_compute_address" "lb_ip" {
  count = var.create_address ? 1 : 0

  name         = "${var.name}-ip"
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = var.network_tier
}

# Health Check
resource "google_compute_region_health_check" "health_check" {
  name                = "${var.name}-health-check"
  project             = var.project_id
  region              = var.region
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

  log_config {
    enable = var.health_check_logging
  }
}

# Backend Service (for regional external network LB)
resource "google_compute_region_backend_service" "backend_service" {
  name                            = "${var.name}-backend"
  project                         = var.project_id
  region                          = var.region
  protocol                        = var.protocol
  load_balancing_scheme           = "EXTERNAL"
  session_affinity                = var.session_affinity
  timeout_sec                     = var.timeout_sec
  connection_draining_timeout_sec = var.connection_draining_timeout_sec
  health_checks                   = [google_compute_region_health_check.health_check.id]
  locality_lb_policy              = var.locality_lb_policy

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
  ip_address            = var.create_address ? google_compute_address.lb_ip[0].address : var.ip_address
  ip_protocol           = var.ip_protocol
  ports                 = var.all_ports ? null : var.ports
  all_ports             = var.all_ports
  load_balancing_scheme = "EXTERNAL"
  backend_service       = google_compute_region_backend_service.backend_service.id
  network_tier          = var.network_tier
  labels                = var.labels
}

# Outputs
output "forwarding_rule_id" {
  value       = google_compute_forwarding_rule.forwarding_rule.id
  description = "The ID of the forwarding rule"
}

output "external_ip" {
  value       = var.create_address ? google_compute_address.lb_ip[0].address : var.ip_address
  description = "The external IP address"
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
  value       = google_compute_region_health_check.health_check.id
  description = "The ID of the health check"
}
