variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "dns_zones" {
  type = map(object({
    name          = string
    dns_name      = string
    description   = optional(string, "Managed by Terraform")
    visibility    = optional(string, "public")
    force_destroy = optional(bool, false)
    labels        = optional(map(string), {})
    enable_logging = optional(bool, false)
    private_visibility_networks      = optional(list(string))
    private_visibility_gke_clusters  = optional(list(string))
    peering_network                  = optional(string)
    forwarding_targets = optional(list(object({
      ipv4_address    = string
      forwarding_path = optional(string, "default")
    })))
    dnssec_config = optional(object({
      state         = optional(string, "on")
      kind          = optional(string, "dns#managedZoneDnsSecConfig")
      non_existence = optional(string, "nsec3")
      default_key_specs = optional(list(object({
        algorithm  = optional(string, "rsasha256")
        key_length = optional(number, 2048)
        key_type   = string
        kind       = optional(string, "dns#dnsKeySpec")
      })))
    }))
  }))
  description = "Map of DNS zone configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.dns_zones : contains(["public", "private"], v.visibility)
    ])
    error_message = "Visibility must be either 'public' or 'private'."
  }
}

variable "dns_records" {
  type = map(object({
    name         = string
    managed_zone = string
    type         = string
    ttl          = optional(number, 300)
    rrdatas      = optional(list(string))
    routing_policy = optional(object({
      geo = optional(list(object({
        location = string
        rrdatas  = list(string)
      })))
      wrr = optional(list(object({
        weight  = number
        rrdatas = list(string)
      })))
    }))
  }))
  description = "Map of DNS record configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.dns_records : contains([
        "A", "AAAA", "CAA", "CNAME", "DNSKEY", "DS", "IPSECKEY", "MX",
        "NAPTR", "NS", "PTR", "SOA", "SPF", "SRV", "SSHFP", "TLSA", "TXT"
      ], v.type)
    ])
    error_message = "Record type must be a valid DNS record type."
  }
}
