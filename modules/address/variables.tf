variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The default GCP region"
  default     = "us-central1"
}

variable "global_addresses" {
  type = map(object({
    description   = optional(string)
    address_type  = optional(string)
    ip_version    = optional(string)
    prefix_length = optional(number)
    address       = optional(string)
    purpose       = optional(string)
    network       = optional(string)
    labels        = optional(map(string))
  }))
  description = "Map of global IP addresses to create"
  default     = {}
}

variable "external_addresses" {
  type = map(object({
    region        = optional(string)
    description   = optional(string)
    network_tier  = optional(string)
    address       = optional(string)
    prefix_length = optional(number)
    labels        = optional(map(string))
  }))
  description = "Map of regional external IP addresses to create"
  default     = {}
}

variable "internal_addresses" {
  type = map(object({
    region       = optional(string)
    description  = optional(string)
    address      = optional(string)
    subnetwork   = string
    purpose      = optional(string)
    network_tier = optional(string)
    labels       = optional(map(string))
  }))
  description = "Map of regional internal IP addresses to create"
  default     = {}
}

variable "psc_addresses" {
  type = map(object({
    description   = optional(string)
    prefix_length = optional(number)
    network       = string
    labels        = optional(map(string))
  }))
  description = "Map of Private Service Connect addresses to create"
  default     = {}
}
