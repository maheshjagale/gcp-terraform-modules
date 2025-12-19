variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us-central1"
}

variable "name" {
  type        = string
  description = "Name prefix for all resources"
}

variable "description" {
  type        = string
  description = "Description for the URL map"
  default     = "HTTP(S) Load Balancer"
}

variable "create_address" {
  type        = bool
  description = "Whether to create a new external IP address"
  default     = true
}

variable "ip_address" {
  type        = string
  description = "Existing IP address (if not creating new)"
  default     = null
}

variable "ip_version" {
  type        = string
  description = "IP version (IPV4 or IPV6)"
  default     = "IPV4"
}

variable "enable_ssl" {
  type        = bool
  description = "Whether to enable HTTPS"
  default     = true
}

variable "enable_http" {
  type        = bool
  description = "Whether to enable HTTP"
  default     = true
}

variable "https_redirect" {
  type        = bool
  description = "Whether to redirect HTTP to HTTPS"
  default     = true
}

variable "ssl_certificates" {
  type        = list(string)
  description = "List of existing SSL certificate self_links"
  default     = null
}

variable "managed_ssl_certificate_domains" {
  type        = list(string)
  description = "Domains for managed SSL certificate"
  default     = null
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy self_link"
  default     = null
}

variable "quic_override" {
  type        = string
  description = "QUIC override setting"
  default     = "NONE"
}

variable "default_service" {
  type        = string
  description = "Key of the default backend service"
}

variable "backends" {
  type = map(object({
    protocol                        = optional(string)
    port_name                       = optional(string)
    timeout_sec                     = optional(number)
    enable_cdn                      = optional(bool)
    custom_request_headers          = optional(list(string))
    custom_response_headers         = optional(list(string))
    security_policy                 = optional(string)
    compression_mode                = optional(string)
    connection_draining_timeout_sec = optional(number)
    groups = list(object({
      group                 = string
      balancing_mode        = optional(string)
      capacity_scaler       = optional(number)
      max_utilization       = optional(number)
      max_rate_per_instance = optional(number)
      max_connections       = optional(number)
    }))
    health_check = object({
      protocol           = optional(string)
      port               = optional(number)
      port_specification = optional(string)
      request_path       = optional(string)
      host               = optional(string)
      check_interval_sec = optional(number)
      timeout_sec        = optional(number)
      healthy_threshold  = optional(number)
      unhealthy_threshold= optional(number)
      logging            = optional(bool)
    })
    cdn_policy = optional(object({
      cache_mode                   = optional(string)
      default_ttl                  = optional(number)
      client_ttl                   = optional(number)
      max_ttl                      = optional(number)
      negative_caching             = optional(bool)
      serve_while_stale            = optional(number)
      signed_url_cache_max_age_sec = optional(number)
    }))
    iap_config = optional(object({
      oauth2_client_id     = string
      oauth2_client_secret = string
    }))
    log_config = optional(object({
      enable      = optional(bool)
      sample_rate = optional(number)
    }))
  }))
  description = "Map of backend configurations"
}

variable "host_rules" {
  type = list(object({
    hosts        = list(string)
    path_matcher = string
  }))
  description = "List of host rules"
  default     = []
}

variable "path_matchers" {
  type = map(object({
    default_service = string
    path_rules = optional(list(object({
      paths   = list(string)
      service = string
    })))
    route_rules = optional(list(object({
      priority = number
      service  = optional(string)
      match_rules = optional(list(object({
        prefix_match    = optional(string)
        full_path_match = optional(string)
        ignore_case     = optional(bool)
      })))
      header_action = optional(object({
        request_headers_to_add = optional(list(object({
          header_name  = string
          header_value = string
          replace      = optional(bool)
        })))
        request_headers_to_remove = optional(list(string))
      }))
      url_redirect = optional(object({
        host_redirect          = optional(string)
        path_redirect          = optional(string)
        prefix_redirect        = optional(string)
        redirect_response_code = optional(string)
        https_redirect         = optional(bool)
        strip_query            = optional(bool)
      }))
    })))
  }))
  description = "Map of path matchers"
  default     = {}
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to resources"
  default     = {}
}
