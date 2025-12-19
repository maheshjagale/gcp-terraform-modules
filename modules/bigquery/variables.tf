variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "datasets" {
  type = map(object({
    dataset_id                  = string
    friendly_name               = optional(string)
    description                 = optional(string)
    location                    = optional(string, "US")
    delete_contents_on_destroy  = optional(bool, false)
    default_table_expiration_ms = optional(number)
    kms_key_name                = optional(string)
    access = optional(list(object({
      role           = string
      user_by_email  = optional(string)
      group_by_email = optional(string)
      special_group  = optional(string)
    })), [])
    labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of BigQuery datasets to create"
}

variable "tables" {
  type = map(object({
    dataset_key         = string
    table_id            = string
    description         = optional(string)
    deletion_protection = optional(bool, true)
    expiration_time     = optional(number)
    schema              = optional(string)
    clustering          = optional(list(string))
    time_partitioning = optional(object({
      type                     = string
      field                    = optional(string)
      expiration_ms            = optional(number)
      require_partition_filter = optional(bool, false)
    }))
    range_partitioning = optional(object({
      field    = string
      start    = number
      end      = number
      interval = number
    }))
    labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of BigQuery tables to create"
}

variable "dataset_iam_members" {
  type = map(object({
    dataset_key = string
    role        = string
    member      = string
  }))
  default     = {}
  description = "IAM members for datasets"
}
