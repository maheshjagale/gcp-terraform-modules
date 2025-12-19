variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The default region for resources"
}

variable "nat_instances" {
  type = map(object({
    nat_name                            = string
    router_name                         = string
    region                              = string
    network                             = string
    router_asn                          = optional(number)
    nat_ip_allocate_option              = optional(string, "AUTO_ONLY")
    source_subnetwork_ip_ranges_to_nat  = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")
    min_ports_per_vm                    = optional(number, 64)
    max_ports_per_vm                    = optional(number, 65536)
    enable_dynamic_port_allocation      = optional(bool, true)
    enable_endpoint_independent_mapping = optional(bool, false)
    icmp_idle_timeout_sec               = optional(number, 30)
    tcp_established_idle_timeout_sec    = optional(number, 1200)
    tcp_transitory_idle_timeout_sec     = optional(number, 30)
    udp_idle_timeout_sec                = optional(number, 30)
    log_config_enable                   = optional(bool, false)
    log_config_filter                   = optional(string, "ERRORS_ONLY")
    subnetworks = optional(list(object({
      name                    = string
      source_ip_ranges_to_nat = list(string)
    })))
  }))
  description = "Map of NAT instance configurations"
  default     = {}
}

variable "nat_static_ips" {
  type = map(object({
    name         = string
    region       = string
    network_tier = optional(string, "PREMIUM")
  }))
  description = "Map of static IP configurations for NAT"
  default     = {}
}
