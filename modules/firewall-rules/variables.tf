variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us-central1"
}

variable "network" {
  type        = string
  description = "The VPC network self_link or ID"
}

variable "network_name" {
  type        = string
  description = "The VPC network name (for naming rules)"
  default     = "vpc"
}

variable "firewall_rules" {
  type = map(object({
    description             = optional(string)
    direction               = optional(string)
    priority                = optional(number)
    disabled                = optional(bool)
    source_ranges           = optional(list(string))
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    destination_ranges      = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
    log_config = optional(object({
      metadata = string
    }))
  }))
  description = "Map of firewall rules to create"
  default     = {}
}

variable "create_common_rules" {
  type        = bool
  description = "Whether to create common firewall rules"
  default     = false
}

variable "internal_ranges" {
  type        = list(string)
  description = "Internal IP ranges for allow-internal rule"
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "allow_iap_ssh" {
  type        = bool
  description = "Whether to create IAP SSH firewall rule"
  default     = true
}

variable "allow_iap_rdp" {
  type        = bool
  description = "Whether to create IAP RDP firewall rule"
  default     = false
}

variable "allow_health_checks" {
  type        = bool
  description = "Whether to create health check firewall rule"
  default     = true
}

variable "deny_all_egress" {
  type        = bool
  description = "Whether to create deny-all-egress rule"
  default     = false
}
