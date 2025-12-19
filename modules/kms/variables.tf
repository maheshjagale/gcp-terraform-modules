
variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "key_rings" {
  type = map(object({
    name     = string
    location = string
  }))
  default     = {}
  description = "Map of KMS key rings to create"
}

variable "crypto_keys" {
  type = map(object({
    name            = string
    key_ring_key    = string
    rotation_period = optional(string, "7776000s")
    purpose         = optional(string, "ENCRYPT_DECRYPT")
    version_template = optional(object({
      algorithm        = string
      protection_level = optional(string, "SOFTWARE")
    }))
    destroy_scheduled_duration    = optional(string)
    import_only                   = optional(bool, false)
    skip_initial_version_creation = optional(bool, false)
    labels                        = optional(map(string), {})
  }))
  default     = {}
  description = "Map of KMS crypto keys to create"
}

variable "crypto_key_iam_members" {
  type = map(object({
    crypto_key_key = string
    role           = string
    member         = string
  }))
  default     = {}
  description = "IAM members for crypto keys"
}

variable "key_ring_iam_members" {
  type = map(object({
    key_ring_key = string
    role         = string
    member       = string
  }))
  default     = {}
  description = "IAM members for key rings"
}
