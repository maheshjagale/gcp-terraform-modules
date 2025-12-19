variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "us-central1"
}

variable "redis_instances" {
  type = map(object({
    name                    = string
    region                  = optional(string)
    tier                    = optional(string, "BASIC")
    memory_size_gb          = number
    redis_version           = optional(string, "REDIS_7_0")
    display_name            = optional(string)
    authorized_network      = optional(string)
    connect_mode            = optional(string, "DIRECT_PEERING")
    auth_enabled            = optional(bool, false)
    transit_encryption_mode = optional(string, "DISABLED")
    replica_count           = optional(number)
    read_replicas_mode      = optional(string)
    location_id             = optional(string)
    alternative_location_id = optional(string)
    reserved_ip_range       = optional(string)
    customer_managed_key    = optional(string)
    redis_configs           = optional(map(string), {})
    maintenance_policy = optional(object({
      day                = string
      start_time_hours   = number
      start_time_minutes = optional(number, 0)
    }))
    persistence_config = optional(object({
      persistence_mode    = string
      rdb_snapshot_period = optional(string)
    }))
    labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Redis instances to create"
}
