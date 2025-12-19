variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "buckets" {
  type = map(object({
    name                        = string
    location                    = string
    storage_class               = optional(string, "STANDARD")
    uniform_bucket_level_access = optional(bool, true)
    force_destroy               = optional(bool, false)
    public_access_prevention    = optional(string, "enforced")
    versioning_enabled          = optional(bool, false)
    kms_key_name                = optional(string)
    log_bucket                  = optional(string)
    log_object_prefix           = optional(string)
    retention_policy = optional(object({
      is_locked        = bool
      retention_period = number
    }))
    lifecycle_rules = optional(list(object({
      action = object({
        type          = string
        storage_class = optional(string)
      })
      condition = object({
        age                   = optional(number)
        created_before        = optional(string)
        with_state            = optional(string)
        matches_storage_class = optional(list(string))
        num_newer_versions    = optional(number)
      })
    })), [])
    labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of GCS buckets to create"
}

variable "bucket_iam_members" {
  type = map(object({
    bucket_key = string
    role       = string
    member     = string
  }))
  default     = {}
  description = "IAM members for buckets"
}
