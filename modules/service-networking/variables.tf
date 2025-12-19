variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "private_service_addresses" {
  type = map(object({
    name          = string
    purpose       = optional(string, "VPC_PEERING")
    address_type  = optional(string, "INTERNAL")
    prefix_length = optional(number, 16)
    address       = optional(string)
    network       = string
    description   = optional(string, "Managed by Terraform")
    labels        = optional(map(string), {})
  }))
  description = "Map of private service address configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.private_service_addresses : contains([
        "VPC_PEERING", "PRIVATE_SERVICE_CONNECT"
      ], v.purpose)
    ])
    error_message = "Purpose must be VPC_PEERING or PRIVATE_SERVICE_CONNECT."
  }
}

variable "private_vpc_connections" {
  type = map(object({
    network                 = string
    service                 = optional(string, "servicenetworking.googleapis.com")
    reserved_peering_ranges = list(string)
    deletion_policy         = optional(string, "NONE")
  }))
  description = "Map of private VPC connection configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.private_vpc_connections : contains(["NONE", "ABANDON"], v.deletion_policy)
    ])
    error_message = "Deletion policy must be either 'NONE' or 'ABANDON'."
  }
}

variable "peered_dns_domains" {
  type = map(object({
    name       = string
    network    = string
    dns_suffix = string
    service    = optional(string, "servicenetworking.googleapis.com")
  }))
  description = "Map of peered DNS domain configurations"
  default     = {}
}

variable "vpc_access_connectors" {
  type = map(object({
    name             = string
    region           = string
    network          = optional(string)
    ip_cidr_range    = optional(string)
    machine_type     = optional(string, "e2-micro")
    min_instances    = optional(number, 2)
    max_instances    = optional(number, 3)
    min_throughput   = optional(number, 200)
    max_throughput   = optional(number, 300)
    subnet_name      = optional(string)
    subnet_project_id = optional(string)
  }))
  description = "Map of VPC Access Connector configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.vpc_access_connectors : contains([
        "f1-micro", "e2-micro", "e2-standard-4"
      ], v.machine_type)
    ])
    error_message = "Machine type must be f1-micro, e2-micro, or e2-standard-4."
  }
}
