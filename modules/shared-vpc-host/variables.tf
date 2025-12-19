variable "host_project_id" {
  type        = string
  description = "The project ID of the Shared VPC host project"
}

variable "enable_shared_vpc_host" {
  type        = bool
  description = "Whether to enable the project as a Shared VPC host"
  default     = true
}

variable "service_projects" {
  type = map(object({
    project_id      = string
    deletion_policy = optional(string)
  }))
  description = "Map of service projects to attach to the host project"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.service_projects : v.deletion_policy == null || contains(["ABANDON"], v.deletion_policy)
    ])
    error_message = "Deletion policy must be null or 'ABANDON'."
  }
}

variable "subnet_iam_bindings" {
  type = map(object({
    region     = string
    subnetwork = string
    role       = optional(string, "roles/compute.networkUser")
    member     = string
  }))
  description = "Map of subnet-level IAM bindings for network users"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.subnet_iam_bindings : can(regex("^(user:|serviceAccount:|group:|domain:)", v.member))
    ])
    error_message = "Member must start with user:, serviceAccount:, group:, or domain:."
  }
}

variable "network_users" {
  type = map(object({
    role   = optional(string, "roles/compute.networkUser")
    member = string
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  description = "Map of project-level IAM bindings for network users"
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.network_users : can(regex("^(user:|serviceAccount:|group:|domain:)", v.member))
    ])
    error_message = "Member must start with user:, serviceAccount:, group:, or domain:."
  }
}

variable "create_lien" {
  type        = bool
  description = "Whether to create a lien to prevent project deletion"
  default     = false
}
