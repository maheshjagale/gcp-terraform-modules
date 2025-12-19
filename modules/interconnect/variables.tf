variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The default region for resources"
}

variable "interconnect_attachments" {
  type = map(object({
    name                     = string
    region                   = string
    router                   = string
    type                     = optional(string, "DEDICATED")
    interconnect             = optional(string)
    description              = optional(string, "Managed by Terraform")
    mtu                      = optional(string, "1500")
    bandwidth                = optional(string, "BPS_10G")
    edge_availability_domain = optional(string, "AVAILABILITY_DOMAIN_1")
    admin_enabled            = optional(bool, true)
    vlan_tag8021q            = optional(number)
    candidate_subnets        = optional(list(string))
    encryption               = optional(string, "NONE")
    ipsec_internal_addresses = optional(list(string))
    stack_type               = optional(string, "IPV4_ONLY")
    router_interface_ip_range = optional(string)
    create_bgp_peer                 = optional(bool, true)
    bgp_peer_asn                    = optional(number)
    bgp_peer_ip_address             = optional(string)
    bgp_advertised_route_priority   = optional(number, 100)
    bgp_advertise_mode              = optional(string, "DEFAULT")
    bgp_advertised_groups           = optional(list(string))
    bgp_advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })))
    bfd_enabled                     = optional(bool, false)
    bfd_session_initialization_mode = optional(string, "ACTIVE")
    bfd_min_transmit_interval       = optional(number, 1000)
    bfd_min_receive_interval        = optional(number, 1000)
    bfd_multiplier                  = optional(number, 5)
  }))
  description = "Map of interconnect attachment configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.interconnect_attachments : contains(["DEDICATED", "PARTNER", "PARTNER_PROVIDER"], v.type)
    ])
    error_message = "Type must be DEDICATED, PARTNER, or PARTNER_PROVIDER."
  }

  validation {
    condition = alltrue([
      for k, v in var.interconnect_attachments : contains([
        "BPS_50M", "BPS_100M", "BPS_200M", "BPS_300M", "BPS_400M", "BPS_500M",
        "BPS_1G", "BPS_2G", "BPS_5G", "BPS_10G", "BPS_20G", "BPS_50G"
      ], v.bandwidth)
    ])
    error_message = "Bandwidth must be a valid interconnect bandwidth value."
  }

  validation {
    condition = alltrue([
      for k, v in var.interconnect_attachments : contains(["NONE", "IPSEC"], v.encryption)
    ])
    error_message = "Encryption must be either 'NONE' or 'IPSEC'."
  }
}
