variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "storage_buckets" {
  type = map(object({
    name                        = string
    location                    = string
    storage_class               = optional(string, "STANDARD")
    uniform_bucket_level_access = optional(bool, true)
    public_access_prevention    = optional(string, "enforced")
    force_destroy               = optional(bool, false)
    labels                      = optional(map(string), {})
    requester_pays              = optional(bool, false)
    default_event_based_hold    = optional(bool, false)
    enable_object_retention     = optional(bool, false)
    versioning_enabled          = optional(bool, false)
    kms_key_name                = optional(string)
    soft_delete_retention_seconds = optional(number)
    lifecycle_rules = optional(list(object({
      action = object({
        type          = string
        storage_class = optional(string)
      })
      condition = object({
        age                        = optional(number)
        created_before             = optional(string)
        with_state                 = optional(string)
        matches_storage_class      = optional(list(string))
        matches_prefix             = optional(list(string))
        matches_suffix             = optional(list(string))
        num_newer_versions         = optional(number)
        days_since_custom_time     = optional(number)
        days_since_noncurrent_time = optional(number)
        noncurrent_time_before     = optional(string)
      })
    })))
    retention_policy = optional(object({
      retention_period = number
      is_locked        = optional(bool, false)
    }))
    website = optional(object({
      main_page_suffix = optional(string)
      not_found_page   = optional(string)
    }))
    cors_rules = optional(list(object({
      origin          = optional(list(string))
      method          = optional(list(string))
      response_header = optional(list(string))
      max_age_seconds = optional(number)
    })))
    logging = optional(object({
      log_bucket        = string
      log_object_prefix = optional(string)
    }))
    custom_placement_config = optional(object({
      data_locations = list(string)
    }))
    autoclass = optional(object({
      enabled                = bool
      terminal_storage_class = optional(string)
    }))
  }))
  description = "Map of storage bucket configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.storage_buckets : contains([
        "STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE", "MULTI_REGIONAL", "REGIONAL"
      ], v.storage_class)
    ])
    error_message = "Storage class must be a valid GCS storage class."
  }

  validation {
    condition = alltrue([
      for k, v in var.storage_buckets : contains(["enforced", "inherited"], v.public_access_prevention)
    ])
    error_message = "Public access prevention must be 'enforced' or 'inherited'."
  }
}

variable "bucket_iam_bindings" {
  type = map(object({
    bucket = string
    role   = string
    member = string
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  description = "Map of bucket IAM binding configurations"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.bucket_iam_bindings : can(regex("^(user:|serviceAccount:|group:|domain:|allUsers|allAuthenticatedUsers)", v.member))
    ])
    error_message = "Member must be a valid IAM member format."
  }
}

variable "bucket_objects" {
  type = map(object({
    name          = string
    bucket        = string
    content       = optional(string)
    content_type  = optional(string, "application/octet-stream")
    source        = optional(string)
    cache_control = optional(string)
    metadata      = optional(map(string))
  }))
  description = "Map of bucket object configurations"
  default     = {}
}
