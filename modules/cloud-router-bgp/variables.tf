variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The default region for resources"
}

variable "cloud_routers" {
  type = map(object({
    name                          = string
    region                        = string
    network                       = string
    description                   = optional(string)
    encrypted_interconnect_router = optional(bool, false)
    bgp_asn                       = number
    bgp_advertise_mode            = optional(string, "DEFAULT")
    bgp_advertised_groups         = optional(list(string))
    bgp_keepalive_interval        = optional(number, 20)
    bgp_advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })))
  }))
  description = "Map of Cloud Router configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.cloud_routers : v.bgp_asn >= 64512 && v.bgp_asn <= 65534 || v.bgp_asn >= 4200000000 && v.bgp_asn <= 4294967294
    ])
    error_message = "BGP ASN must be in private range: 64512-65534 or 4200000000-4294967294."
  }

  validation {
    condition = alltrue([
      for k, v in var.cloud_routers : contains(["DEFAULT", "CUSTOM"], v.bgp_advertise_mode)
    ])
    error_message = "BGP advertise mode must be either 'DEFAULT' or 'CUSTOM'."
  }
}

variable "router_interfaces" {
  type = map(object({
    name                    = string
    region                  = string
    router                  = string
    ip_range                = optional(string)
    vpn_tunnel              = optional(string)
    interconnect_attachment = optional(string)
    subnetwork              = optional(string)
    private_ip_address      = optional(string)
    redundant_interface     = optional(string)
  }))
  description = "Map of router interface configurations"
  default     = {}
}

variable "bgp_peers" {
  type = map(object({
    name                      = string
    region                    = string
    router                    = string
    interface                 = string
    peer_asn                  = number
    peer_ip_address           = optional(string)
    ip_address                = optional(string)
    advertised_route_priority = optional(number, 100)
    advertise_mode            = optional(string, "DEFAULT")
    advertised_groups         = optional(list(string))
    enable                    = optional(bool, true)
    enable_ipv6               = optional(bool, false)
    ipv6_nexthop_address      = optional(string)
    peer_ipv6_nexthop_address = optional(string)
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })))
    bfd = optional(object({
      session_initialization_mode = optional(string, "ACTIVE")
      min_transmit_interval       = optional(number, 1000)
      min_receive_interval        = optional(number, 1000)
      multiplier                  = optional(number, 5)
    }))
  }))
  description = "Map of BGP peer configurations"
  default     = {}
}
