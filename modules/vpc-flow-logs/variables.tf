variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The default region for resources"
}

variable "vpc_flow_logs" {
  type = map(object({
    subnet_name              = string
    region                   = string
    network                  = string
    ip_cidr_range            = string
    private_ip_google_access = optional(bool, true)
    enable_flow_logs         = optional(bool, true)
    aggregation_interval     = optional(string, "INTERVAL_5_SEC")
    flow_sampling            = optional(number, 0.5)
    metadata                 = optional(string, "INCLUDE_ALL_METADATA")
    metadata_fields          = optional(list(string))
    filter_expr              = optional(string)
  }))
  description = "Map of VPC flow log configurations for subnets"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.vpc_flow_logs : contains([
        "INTERVAL_5_SEC", "INTERVAL_30_SEC", "INTERVAL_1_MIN",
        "INTERVAL_5_MIN", "INTERVAL_10_MIN", "INTERVAL_15_MIN"
      ], v.aggregation_interval)
    ])
    error_message = "Aggregation interval must be a valid value."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpc_flow_logs : v.flow_sampling >= 0 && v.flow_sampling <= 1
    ])
    error_message = "Flow sampling must be between 0 and 1."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpc_flow_logs : contains([
        "INCLUDE_ALL_METADATA", "EXCLUDE_ALL_METADATA", "CUSTOM_METADATA"
      ], v.metadata)
    ])
    error_message = "Metadata must be INCLUDE_ALL_METADATA, EXCLUDE_ALL_METADATA, or CUSTOM_METADATA."
  }
}

variable "flow_log_sinks" {
  type = map(object({
    name                   = string
    destination            = string
    filter                 = optional(string)
    unique_writer_identity = optional(bool, true)
    use_partitioned_tables = optional(bool)
    exclusions = optional(list(object({
      name        = string
      description = optional(string)
      filter      = string
    })))
  }))
  description = "Map of log sink configurations for VPC flow logs"
  default     = {}
}
