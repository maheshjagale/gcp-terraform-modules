variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
}

variable "name" {
  type        = string
  description = "The name of the Cloud NAT"
}

variable "network" {
  type        = string
  description = "The VPC network self_link or name"
}

variable "create_router" {
  type        = bool
  description = "Whether to create a new Cloud Router"
  default     = true
}

variable "router_name" {
  type        = string
  description = "The name of the Cloud Router (existing or new)"
  default     = ""
}

variable "router_asn" {
  type        = number
  description = "The BGP ASN for the Cloud Router"
  default     = 64514
}

variable "router_advertise_mode" {
  type        = string
  description = "The advertise mode for the router (DEFAULT or CUSTOM)"
  default     = "DEFAULT"
}

variable "router_advertised_groups" {
  type        = list(string)
  description = "Advertised groups for custom mode"
  default     = []
}

variable "router_advertised_ip_ranges" {
  type = list(object({
    range       = string
    description = optional(string)
  }))
  description = "Advertised IP ranges for custom mode"
  default     = []
}

variable "router_keepalive_interval" {
  type        = number
  description = "Router keepalive interval in seconds"
  default     = 20
}

variable "nat_ip_allocate_option" {
  type        = string
  description = "How NAT IPs are allocated (AUTO_ONLY or MANUAL_ONLY)"
  default     = "AUTO_ONLY"

  validation {
    condition     = contains(["AUTO_ONLY", "MANUAL_ONLY"], var.nat_ip_allocate_option)
    error_message = "nat_ip_allocate_option must be AUTO_ONLY or MANUAL_ONLY"
  }
}

variable "nat_ips" {
  type        = list(string)
  description = "List of NAT IP self_links (for MANUAL_ONLY)"
  default     = []
}

variable "source_subnetwork_ip_ranges_to_nat" {
  type        = string
  description = "How subnetworks are NATed"
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  validation {
    condition = contains([
      "ALL_SUBNETWORKS_ALL_IP_RANGES",
      "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES",
      "LIST_OF_SUBNETWORKS"
    ], var.source_subnetwork_ip_ranges_to_nat)
    error_message = "Invalid source_subnetwork_ip_ranges_to_nat value"
  }
}

variable "subnetworks" {
  type = list(object({
    name                     = string
    source_ip_ranges_to_nat  = list(string)
    secondary_ip_range_names = optional(list(string))
  }))
  description = "List of subnetworks for LIST_OF_SUBNETWORKS option"
  default     = []
}

variable "min_ports_per_vm" {
  type        = number
  description = "Minimum number of ports per VM"
  default     = 64
}

variable "max_ports_per_vm" {
  type        = number
  description = "Maximum number of ports per VM (for dynamic allocation)"
  default     = null
}

variable "enable_dynamic_port_allocation" {
  type        = bool
  description = "Whether to enable dynamic port allocation"
  default     = false
}

variable "enable_endpoint_independent_mapping" {
  type        = bool
  description = "Whether to enable endpoint independent mapping"
  default     = null
}

variable "udp_idle_timeout_sec" {
  type        = number
  description = "UDP idle timeout in seconds"
  default     = 30
}

variable "icmp_idle_timeout_sec" {
  type        = number
  description = "ICMP idle timeout in seconds"
  default     = 30
}

variable "tcp_established_idle_timeout_sec" {
  type        = number
  description = "TCP established idle timeout in seconds"
  default     = 1200
}

variable "tcp_transitory_idle_timeout_sec" {
  type        = number
  description = "TCP transitory idle timeout in seconds"
  default     = 30
}

variable "tcp_time_wait_timeout_sec" {
  type        = number
  description = "TCP TIME_WAIT timeout in seconds"
  default     = 120
}

variable "log_config_enable" {
  type        = bool
  description = "Whether to enable logging"
  default     = true
}

variable "log_config_filter" {
  type        = string
  description = "Log filter (ERRORS_ONLY, TRANSLATIONS_ONLY, ALL)"
  default     = "ALL"
}

variable "nat_rules" {
  type = list(object({
    rule_number = number
    description = optional(string)
    match       = string
    action = object({
      source_nat_active_ips = optional(list(string))
      source_nat_drain_ips  = optional(list(string))
    })
  }))
  description = "List of NAT rules"
  default     = []
}
