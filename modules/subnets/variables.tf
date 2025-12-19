variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The default region for resources"
}

variable "subnets" {
  type = map(object({
    name                       = string
    region                     = string
    network                    = string
    ip_cidr_range              = string
    purpose                    = optional(string, "PRIVATE")
    role                       = optional(string)
    private_ip_google_access   = optional(bool, true)
    private_ipv6_google_access = optional(string)
    stack_type                 = optional(string, "IPV4_ONLY")
    ipv6_access_type           = optional(string)
    description                = optional(string)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })))
    log_config = optional(object({
      aggregation_interval = optional(string, "INTERVAL_5_SEC")
      flow_sampling        = optional(number, 0.5)
      metadata             = optional(string, "INCLUDE_ALL_METADATA")
      metadata_fields      = optional(list(string))
      filter_expr          = optional(string)
    }))
  }))
  description = "Map of subnet configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.subnets : contains([
        "PRIVATE", "PRIVATE_RFC_1918", "PRIVATE_NAT", "REGIONAL_MANAGED_PROXY",
        "GLOBAL_MANAGED_PROXY", "INTERNAL_HTTPS_LOAD_BALANCER"
      ], v.purpose)
    ])
    error_message = "Purpose must be a valid subnet purpose."
  }
}
