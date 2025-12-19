
variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "project_sinks" {
  type = map(object({
    name                   = string
    destination            = string
    filter                 = optional(string)
    unique_writer_identity = optional(bool, true)
    disabled               = optional(bool, false)
    description            = optional(string)
    bigquery_options = optional(object({
      use_partitioned_tables = bool
    }))
    exclusions = optional(list(object({
      name        = string
      description = optional(string)
      filter      = string
      disabled    = optional(bool, false)
    })))
  }))
  default     = {}
  description = "Map of project-level log sinks"
}

variable "folder_sinks" {
  type = map(object({
    name             = string
    folder           = string
    destination      = string
    filter           = optional(string)
    include_children = optional(bool, true)
    disabled         = optional(bool, false)
    description      = optional(string)
    bigquery_options = optional(object({
      use_partitioned_tables = bool
    }))
    exclusions = optional(list(object({
      name        = string
      description = optional(string)
      filter      = string
      disabled    = optional(bool, false)
    })))
  }))
  default     = {}
  description = "Map of folder-level log sinks"
}

variable "org_sinks" {
  type = map(object({
    name             = string
    org_id           = string
    destination      = string
    filter           = optional(string)
    include_children = optional(bool, true)
    disabled         = optional(bool, false)
    description      = optional(string)
    bigquery_options = optional(object({
      use_partitioned_tables = bool
    }))
    exclusions = optional(list(object({
      name        = string
      description = optional(string)
      filter      = string
      disabled    = optional(bool, false)
    })))
  }))
  default     = {}
  description = "Map of organization-level log sinks"
}

variable "log_buckets" {
  type = map(object({
    bucket_id      = string
    location       = string
    description    = optional(string)
    retention_days = optional(number, 30)
    locked         = optional(bool, false)
    kms_key_name   = optional(string)
  }))
  default     = {}
  description = "Map of log buckets to create"
}

variable "log_metrics" {
  type = map(object({
    name        = string
    filter      = string
    description = optional(string)
    disabled    = optional(bool, false)
    metric_descriptor = optional(object({
      metric_kind  = string
      value_type   = string
      unit         = optional(string, "1")
      display_name = optional(string)
      labels = optional(list(object({
        key         = string
        value_type  = optional(string, "STRING")
        description = optional(string)
      })))
    }))
    label_extractors = optional(map(string))
    bucket_options = optional(object({
      linear_buckets = optional(object({
        num_finite_buckets = number
        width              = number
        offset             = optional(number, 0)
      }))
      exponential_buckets = optional(object({
        num_finite_buckets = number
        growth_factor      = number
        scale              = optional(number, 1)
      }))
      explicit_buckets = optional(object({
        bounds = list(number)
      }))
    }))
  }))
  default     = {}
  description = "Map of log-based metrics to create"
}
