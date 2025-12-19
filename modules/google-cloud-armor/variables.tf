variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us-central1"
}

variable "policy_name" {
  type        = string
  description = "The name of the security policy"
}

variable "description" {
  type        = string
  description = "Description of the security policy"
  default     = "Cloud Armor security policy"
}

variable "policy_type" {
  type        = string
  description = "Type of security policy (CLOUD_ARMOR or CLOUD_ARMOR_EDGE)"
  default     = "CLOUD_ARMOR"
}

variable "default_rule_action" {
  type        = string
  description = "Action for the default rule (allow or deny)"
  default     = "allow"
}

variable "adaptive_protection_config" {
  type = object({
    enable          = bool
    rule_visibility = optional(string)
  })
  description = "Adaptive protection configuration"
  default     = null
}

variable "json_parsing" {
  type        = string
  description = "JSON parsing mode (DISABLED, STANDARD, STANDARD_WITH_GRAPHQL)"
  default     = "DISABLED"
}

variable "log_level" {
  type        = string
  description = "Log level (NORMAL or VERBOSE)"
  default     = "NORMAL"
}

variable "json_custom_config" {
  type = object({
    content_types = list(string)
  })
  description = "Custom JSON configuration"
  default     = null
}

variable "recaptcha_redirect_site_key" {
  type        = string
  description = "reCAPTCHA site key for redirect"
  default     = null
}

variable "rules" {
  type = list(object({
    action      = string
    priority    = number
    description = optional(string)
    preview     = optional(bool)
    match = object({
      versioned_expr = optional(string)
      config = optional(object({
        src_ip_ranges = list(string)
      }))
      expr = optional(object({
        expression = string
      }))
    })
    rate_limit_options = optional(object({
      conform_action      = optional(string)
      exceed_action       = optional(string)
      enforce_on_key      = optional(string)
      enforce_on_key_name = optional(string)
      ban_duration_sec    = optional(number)
      rate_limit_threshold = optional(object({
        count        = number
        interval_sec = number
      }))
      ban_threshold = optional(object({
        count        = number
        interval_sec = number
      }))
      exceed_redirect_options = optional(object({
        type   = string
        target = optional(string)
      }))
    }))
    redirect_options = optional(object({
      type   = string
      target = optional(string)
    }))
    header_action = optional(object({
      request_headers_to_adds = optional(list(object({
        header_name  = string
        header_value = string
      })))
    }))
    preconfigured_waf_config = optional(object({
      exclusions = optional(list(object({
        target_rule_set = string
        target_rule_ids = optional(list(string))
        request_header = optional(list(object({
          operator = string
          value    = optional(string)
        })))
        request_cookie = optional(list(object({
          operator = string
          value    = optional(string)
        })))
        request_uri = optional(list(object({
          operator = string
          value    = optional(string)
        })))
        request_query_param = optional(list(object({
          operator = string
          value    = optional(string)
        })))
      })))
    }))
  }))
  description = "List of security policy rules"
  default     = []
}
