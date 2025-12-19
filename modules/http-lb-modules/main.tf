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

# Reserved External IP
resource "google_compute_global_address" "lb_ip" {
  count = var.create_address ? 1 : 0

  name         = "${var.name}-ip"
  project      = var.project_id
  ip_version   = var.ip_version
  address_type = "EXTERNAL"
}

# SSL Certificate (Managed)
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  count = var.ssl_certificates == null && var.managed_ssl_certificate_domains != null ? 1 : 0

  name    = "${var.name}-ssl-cert"
  project = var.project_id

  managed {
    domains = var.managed_ssl_certificate_domains
  }
}

# Health Check
resource "google_compute_health_check" "http_health_check" {
  for_each = var.backends

  name                = "${var.name}-${each.key}-hc"
  project             = var.project_id
  check_interval_sec  = lookup(each.value.health_check, "check_interval_sec", 5)
  timeout_sec         = lookup(each.value.health_check, "timeout_sec", 5)
  healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 2)
  unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 2)

  dynamic "http_health_check" {
    for_each = lookup(each.value.health_check, "protocol", "HTTP") == "HTTP" ? [1] : []
    content {
      port               = lookup(each.value.health_check, "port", 80)
      port_specification = lookup(each.value.health_check, "port_specification", "USE_FIXED_PORT")
      request_path       = lookup(each.value.health_check, "request_path", "/")
      host               = lookup(each.value.health_check, "host", null)
    }
  }

  dynamic "https_health_check" {
    for_each = lookup(each.value.health_check, "protocol", "HTTP") == "HTTPS" ? [1] : []
    content {
      port               = lookup(each.value.health_check, "port", 443)
      port_specification = lookup(each.value.health_check, "port_specification", "USE_FIXED_PORT")
      request_path       = lookup(each.value.health_check, "request_path", "/")
      host               = lookup(each.value.health_check, "host", null)
    }
  }

  log_config {
    enable = lookup(each.value.health_check, "logging", false)
  }
}

# Backend Service
resource "google_compute_backend_service" "backend_service" {
  for_each = var.backends

  name                            = "${var.name}-${each.key}-backend"
  project                         = var.project_id
  protocol                        = lookup(each.value, "protocol", "HTTP")
  port_name                       = lookup(each.value, "port_name", "http")
  timeout_sec                     = lookup(each.value, "timeout_sec", 30)
  enable_cdn                      = lookup(each.value, "enable_cdn", false)
  custom_request_headers          = lookup(each.value, "custom_request_headers", null)
  custom_response_headers         = lookup(each.value, "custom_response_headers", null)
  security_policy                 = lookup(each.value, "security_policy", null)
  compression_mode                = lookup(each.value, "compression_mode", null)
  connection_draining_timeout_sec = lookup(each.value, "connection_draining_timeout_sec", 300)
  load_balancing_scheme           = "EXTERNAL"
  health_checks                   = [google_compute_health_check.http_health_check[each.key].id]

  dynamic "backend" {
    for_each = each.value.groups
    content {
      group                 = backend.value.group
      balancing_mode        = lookup(backend.value, "balancing_mode", "UTILIZATION")
      capacity_scaler       = lookup(backend.value, "capacity_scaler", 1.0)
      max_utilization       = lookup(backend.value, "max_utilization", 0.8)
      max_rate_per_instance = lookup(backend.value, "max_rate_per_instance", null)
      max_connections       = lookup(backend.value, "max_connections", null)
    }
  }

  dynamic "cdn_policy" {
    for_each = lookup(each.value, "enable_cdn", false) ? [1] : []
    content {
      cache_mode                   = lookup(each.value.cdn_policy, "cache_mode", "CACHE_ALL_STATIC")
      default_ttl                  = lookup(each.value.cdn_policy, "default_ttl", 3600)
      client_ttl                   = lookup(each.value.cdn_policy, "client_ttl", 3600)
      max_ttl                      = lookup(each.value.cdn_policy, "max_ttl", 86400)
      negative_caching             = lookup(each.value.cdn_policy, "negative_caching", false)
      serve_while_stale            = lookup(each.value.cdn_policy, "serve_while_stale", 0)
      signed_url_cache_max_age_sec = lookup(each.value.cdn_policy, "signed_url_cache_max_age_sec", null)
    }
  }

  dynamic "iap" {
    for_each = lookup(each.value, "iap_config", null) != null ? [each.value.iap_config] : []
    content {
      oauth2_client_id     = iap.value.oauth2_client_id
      oauth2_client_secret = iap.value.oauth2_client_secret
    }
  }

  dynamic "log_config" {
    for_each = lookup(each.value, "log_config", null) != null ? [each.value.log_config] : []
    content {
      enable      = lookup(log_config.value, "enable", true)
      sample_rate = lookup(log_config.value, "sample_rate", 1.0)
    }
  }
}

# URL Map
resource "google_compute_url_map" "url_map" {
  name            = "${var.name}-url-map"
  project         = var.project_id
  description     = var.description
  default_service = google_compute_backend_service.backend_service[var.default_service].id

  dynamic "host_rule" {
    for_each = var.host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = var.path_matchers
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_service.backend_service[path_matcher.value.default_service].id

      dynamic "path_rule" {
        for_each = lookup(path_matcher.value, "path_rules", [])
        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_service.backend_service[path_rule.value.service].id
        }
      }

      dynamic "route_rules" {
        for_each = lookup(path_matcher.value, "route_rules", [])
        content {
          priority = route_rules.value.priority
          service  = lookup(route_rules.value, "service", null) != null ? google_compute_backend_service.backend_service[route_rules.value.service].id : null

          dynamic "match_rules" {
            for_each = lookup(route_rules.value, "match_rules", [])
            content {
              prefix_match = lookup(match_rules.value, "prefix_match", null)
              full_path_match = lookup(match_rules.value, "full_path_match", null)
              ignore_case  = lookup(match_rules.value, "ignore_case", false)
            }
          }

          dynamic "header_action" {
            for_each = lookup(route_rules.value, "header_action", null) != null ? [route_rules.value.header_action] : []
            content {
              dynamic "request_headers_to_add" {
                for_each = lookup(header_action.value, "request_headers_to_add", [])
                content {
                  header_name  = request_headers_to_add.value.header_name
                  header_value = request_headers_to_add.value.header_value
                  replace      = lookup(request_headers_to_add.value, "replace", true)
                }
              }
              request_headers_to_remove = lookup(header_action.value, "request_headers_to_remove", null)
            }
          }

          dynamic "url_redirect" {
            for_each = lookup(route_rules.value, "url_redirect", null) != null ? [route_rules.value.url_redirect] : []
            content {
              host_redirect          = lookup(url_redirect.value, "host_redirect", null)
              path_redirect          = lookup(url_redirect.value, "path_redirect", null)
              prefix_redirect        = lookup(url_redirect.value, "prefix_redirect", null)
              redirect_response_code = lookup(url_redirect.value, "redirect_response_code", null)
              https_redirect         = lookup(url_redirect.value, "https_redirect", null)
              strip_query            = lookup(url_redirect.value, "strip_query", false)
            }
          }
        }
      }
    }
  }
}

# HTTPS Target Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  count = var.enable_ssl ? 1 : 0

  name             = "${var.name}-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = var.ssl_certificates != null ? var.ssl_certificates : [google_compute_managed_ssl_certificate.ssl_cert[0].id]
  ssl_policy       = var.ssl_policy
  quic_override    = var.quic_override
}

# HTTP Target Proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  count = var.enable_http ? 1 : 0

  name    = "${var.name}-http-proxy"
  project = var.project_id
  url_map = var.https_redirect && var.enable_ssl ? google_compute_url_map.https_redirect[0].id : google_compute_url_map.url_map.id
}

# HTTPS Redirect URL Map
resource "google_compute_url_map" "https_redirect" {
  count = var.https_redirect && var.enable_ssl ? 1 : 0

  name    = "${var.name}-https-redirect"
  project = var.project_id

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# HTTPS Forwarding Rule
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  count = var.enable_ssl ? 1 : 0

  name                  = "${var.name}-https-fwd-rule"
  project               = var.project_id
  ip_address            = var.create_address ? google_compute_global_address.lb_ip[0].address : var.ip_address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.https_proxy[0].id
  load_balancing_scheme = "EXTERNAL"
  labels                = var.labels
}

# HTTP Forwarding Rule
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  count = var.enable_http ? 1 : 0

  name                  = "${var.name}-http-fwd-rule"
  project               = var.project_id
  ip_address            = var.create_address ? google_compute_global_address.lb_ip[0].address : var.ip_address
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http_proxy[0].id
  load_balancing_scheme = "EXTERNAL"
  labels                = var.labels
}

# Outputs
output "external_ip" {
  value       = var.create_address ? google_compute_global_address.lb_ip[0].address : var.ip_address
  description = "The external IP address of the load balancer"
}

output "url_map_id" {
  value       = google_compute_url_map.url_map.id
  description = "The URL map ID"
}

output "backend_service_ids" {
  value       = { for k, v in google_compute_backend_service.backend_service : k => v.id }
  description = "Map of backend service IDs"
}

output "https_proxy_id" {
  value       = var.enable_ssl ? google_compute_target_https_proxy.https_proxy[0].id : null
  description = "The HTTPS proxy ID"
}

output "http_proxy_id" {
  value       = var.enable_http ? google_compute_target_http_proxy.http_proxy[0].id : null
  description = "The HTTP proxy ID"
}

output "ssl_certificate_ids" {
  value       = var.ssl_certificates != null ? var.ssl_certificates : (var.managed_ssl_certificate_domains != null ? [google_compute_managed_ssl_certificate.ssl_cert[0].id] : [])
  description = "The SSL certificate IDs"
}

output "health_check_ids" {
  value       = { for k, v in google_compute_health_check.http_health_check : k => v.id }
  description = "Map of health check IDs"
}
