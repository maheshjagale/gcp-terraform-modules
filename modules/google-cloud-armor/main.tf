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

# Security Policy
resource "google_compute_security_policy" "policy" {
  name        = var.policy_name
  project     = var.project_id
  description = var.description
  type        = var.policy_type

  # Adaptive Protection
  dynamic "adaptive_protection_config" {
    for_each = var.adaptive_protection_config != null ? [var.adaptive_protection_config] : []
    content {
      layer_7_ddos_defense_config {
        enable          = adaptive_protection_config.value.enable
        rule_visibility = lookup(adaptive_protection_config.value, "rule_visibility", "STANDARD")
      }
    }
  }

  # Advanced Options
  advanced_options_config {
    json_parsing = var.json_parsing
    log_level    = var.log_level

    dynamic "json_custom_config" {
      for_each = var.json_custom_config != null ? [var.json_custom_config] : []
      content {
        content_types = json_custom_config.value.content_types
      }
    }
  }

  # Recaptcha Options
  dynamic "recaptcha_options_config" {
    for_each = var.recaptcha_redirect_site_key != null ? [1] : []
    content {
      redirect_site_key = var.recaptcha_redirect_site_key
    }
  }

  # Default Rule (required)
  rule {
    action   = var.default_rule_action
    priority = 2147483647
    description = "Default rule"
    
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  # Custom Rules
  dynamic "rule" {
    for_each = var.rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = lookup(rule.value, "description", null)
      preview     = lookup(rule.value, "preview", false)

      match {
        versioned_expr = lookup(rule.value.match, "versioned_expr", null)
        
        dynamic "config" {
          for_each = lookup(rule.value.match, "config", null) != null ? [rule.value.match.config] : []
          content {
            src_ip_ranges = lookup(config.value, "src_ip_ranges", null)
          }
        }

        dynamic "expr" {
          for_each = lookup(rule.value.match, "expr", null) != null ? [rule.value.match.expr] : []
          content {
            expression = expr.value.expression
          }
        }
      }

      dynamic "rate_limit_options" {
        for_each = lookup(rule.value, "rate_limit_options", null) != null ? [rule.value.rate_limit_options] : []
        content {
          conform_action = lookup(rate_limit_options.value, "conform_action", "allow")
          exceed_action  = lookup(rate_limit_options.value, "exceed_action", "deny(429)")
          enforce_on_key = lookup(rate_limit_options.value, "enforce_on_key", "IP")
          enforce_on_key_name = lookup(rate_limit_options.value, "enforce_on_key_name", null)
          ban_duration_sec    = lookup(rate_limit_options.value, "ban_duration_sec", null)

          dynamic "rate_limit_threshold" {
            for_each = lookup(rate_limit_options.value, "rate_limit_threshold", null) != null ? [rate_limit_options.value.rate_limit_threshold] : []
            content {
              count        = rate_limit_threshold.value.count
              interval_sec = rate_limit_threshold.value.interval_sec
            }
          }

          dynamic "ban_threshold" {
            for_each = lookup(rate_limit_options.value, "ban_threshold", null) != null ? [rate_limit_options.value.ban_threshold] : []
            content {
              count        = ban_threshold.value.count
              interval_sec = ban_threshold.value.interval_sec
            }
          }

          dynamic "exceed_redirect_options" {
            for_each = lookup(rate_limit_options.value, "exceed_redirect_options", null) != null ? [rate_limit_options.value.exceed_redirect_options] : []
            content {
              type   = exceed_redirect_options.value.type
              target = lookup(exceed_redirect_options.value, "target", null)
            }
          }
        }
      }

      dynamic "redirect_options" {
        for_each = lookup(rule.value, "redirect_options", null) != null ? [rule.value.redirect_options] : []
        content {
          type   = redirect_options.value.type
          target = lookup(redirect_options.value, "target", null)
        }
      }

      dynamic "header_action" {
        for_each = lookup(rule.value, "header_action", null) != null ? [rule.value.header_action] : []
        content {
          dynamic "request_headers_to_adds" {
            for_each = lookup(header_action.value, "request_headers_to_adds", [])
            content {
              header_name  = request_headers_to_adds.value.header_name
              header_value = request_headers_to_adds.value.header_value
            }
          }
        }
      }

      dynamic "preconfigured_waf_config" {
        for_each = lookup(rule.value, "preconfigured_waf_config", null) != null ? [rule.value.preconfigured_waf_config] : []
        content {
          dynamic "exclusion" {
            for_each = lookup(preconfigured_waf_config.value, "exclusions", [])
            content {
              target_rule_set = exclusion.value.target_rule_set
              target_rule_ids = lookup(exclusion.value, "target_rule_ids", null)

              dynamic "request_header" {
                for_each = lookup(exclusion.value, "request_header", [])
                content {
                  operator = request_header.value.operator
                  value    = lookup(request_header.value, "value", null)
                }
              }

              dynamic "request_cookie" {
                for_each = lookup(exclusion.value, "request_cookie", [])
                content {
                  operator = request_cookie.value.operator
                  value    = lookup(request_cookie.value, "value", null)
                }
              }

              dynamic "request_uri" {
                for_each = lookup(exclusion.value, "request_uri", [])
                content {
                  operator = request_uri.value.operator
                  value    = lookup(request_uri.value, "value", null)
                }
              }

              dynamic "request_query_param" {
                for_each = lookup(exclusion.value, "request_query_param", [])
                content {
                  operator = request_query_param.value.operator
                  value    = lookup(request_query_param.value, "value", null)
                }
              }
            }
          }
        }
      }
    }
  }
}

# Outputs
output "policy_id" {
  value       = google_compute_security_policy.policy.id
  description = "The ID of the security policy"
}

output "policy_name" {
  value       = google_compute_security_policy.policy.name
  description = "The name of the security policy"
}

output "policy_self_link" {
  value       = google_compute_security_policy.policy.self_link
  description = "The self_link of the security policy"
}

output "policy_fingerprint" {
  value       = google_compute_security_policy.policy.fingerprint
  description = "The fingerprint of the security policy"
}

output "rule_priorities" {
  value       = [for r in var.rules : r.priority]
  description = "List of rule priorities"
}
