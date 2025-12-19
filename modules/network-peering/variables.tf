variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "network_peerings" {
  type = map(object({
    name                                = string
    network                             = string
    network_name                        = optional(string)
    peer_network                        = string
    export_custom_routes                = optional(bool, false)
    import_custom_routes                = optional(bool, false)
    export_subnet_routes_with_public_ip = optional(bool, true)
    import_subnet_routes_with_public_ip = optional(bool, false)
    stack_type                          = optional(string, "IPV4_ONLY")
    configure_routes                    = optional(bool, false)
  }))
  description = "Map of VPC network peering configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.network_peerings : contains(["IPV4_ONLY", "IPV4_IPV6"], v.stack_type)
    ])
    error_message = "Stack type must be either 'IPV4_ONLY' or 'IPV4_IPV6'."
  }
}
