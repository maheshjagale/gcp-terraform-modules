
variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "Default region for repositories"
  default     = "us-central1"
}

variable "repositories" {
  type = map(object({
    repository_id          = string
    description            = optional(string, "")
    format                 = string
    mode                   = optional(string, "STANDARD_REPOSITORY")
    location               = optional(string)
    cleanup_policy_dry_run = optional(bool, false)
    docker_config = optional(object({
      immutable_tags = optional(bool, false)
    }))
    maven_config = optional(object({
      allow_snapshot_overwrites = optional(bool, false)
      version_policy            = optional(string, "VERSION_POLICY_UNSPECIFIED")
    }))
    labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Artifact Registry repositories to create"
}

variable "iam_members" {
  type = map(object({
    repository_key = string
    role           = string
    member         = string
  }))
  default     = {}
  description = "IAM members for repositories"
}
