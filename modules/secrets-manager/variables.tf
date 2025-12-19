
variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "secrets" {
  type = map(object({
    secret_id        = string
    replication_type = optional(string, "automatic")
    replicas = optional(list(object({
      location     = string
      kms_key_name = optional(string)
    })), [])
    rotation = optional(object({
      next_rotation_time = optional(string)
      rotation_period    = optional(string)
    }))
    topics          = optional(list(string))
    expire_time     = optional(string)
    ttl             = optional(string)
    version_aliases = optional(map(string))
    annotations     = optional(map(string), {})
    labels          = optional(map(string), {})
  }))
  default     = {}
  description = "Map of secrets to create"
}

variable "secret_versions" {
  type = map(object({
    secret_key      = string
    secret_data     = string
    enabled         = optional(bool, true)
    deletion_policy = optional(string)
  }))
  default     = {}
  sensitive   = true
  description = "Map of secret versions to create"
}

variable "secret_iam_members" {
  type = map(object({
    secret_key = string
    role       = string
    member     = string
  }))
  default     = {}
  description = "IAM members for secrets"
}
