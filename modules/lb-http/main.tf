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

resource "google_compute_health_check" "http" {
  name    = "${var.name}-health-check"
  project = var.project_id

  http_health_check {
    port = var.health_check_port
  }
}

resource "google_compute_backend_service" "backend" {
  name            = "${var.name}-backend"
  project         = var.project_id
  load_balancing_scheme = "EXTERNAL"
  health_checks   = [google_compute_health_check.http.id]

  dynamic "backend" {
    for_each = var.backends
    content {
      group           = backend.value.group
      balancing_mode  = backend.value.balancing_mode
      max_rate        = backend.value.max_rate
    }
  }
}

resource "google_compute_url_map" "http_lb" {
  name            = "${var.name}-lb"
  project         = var.project_id
  default_service = google_compute_backend_service.backend.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.http_lb.id
}

resource "google_compute_global_forwarding_rule" "http_lb" {
  name                  = "${var.name}-forwarding-rule"
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
  load_balancer_type    = "EXTERNAL"
  port_range            = var.port_range
  target                = google_compute_target_http_proxy.http_proxy.id
}

output "load_balancer_ip" {
  value       = google_compute_global_forwarding_rule.http_lb.ip_address
  description = "Load balancer IP address"
}
