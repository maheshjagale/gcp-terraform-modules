
variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "scc_sources" {
  type = map(object({
    display_name = string
    organization = string
    description  = optional(string)
  }))
  default     = {}
  description = "Map of SCC sources to create"
}

variable "notification_configs" {
  type = map(object({
    config_id    = string
    organization = string
    description  = optional(string)
    pubsub_topic = string
    filter       = string
  }))
  default     = {}
  description = "Map of SCC notification configs to create"
}

variable "mute_configs" {
  type = map(object({
    mute_config_id = string
    parent         = string
    filter         = string
    description    = optional(string)
  }))
  default     = {}
  description = "Map of SCC mute configs to create"
}

variable "folder_custom_modules" {
  type = map(object({
    folder               = string
    display_name         = string
    enablement_state     = optional(string, "ENABLED")
    predicate_expression = string
    resource_types       = list(string)
    description          = optional(string)
    recommendation       = optional(string)
    severity             = optional(string, "MEDIUM")
  }))
  default     = {}
  description = "Map of folder-level custom modules"
}

variable "org_custom_modules" {
  type = map(object({
    organization         = string
    display_name         = string
    enablement_state     = optional(string, "ENABLED")
    predicate_expression = string
    resource_types       = list(string)
    description          = optional(string)
    recommendation       = optional(string)
    severity             = optional(string, "MEDIUM")
  }))
  default     = {}
  description = "Map of organization-level custom modules"
}

variable "project_custom_modules" {
  type = map(object({
    display_name         = string
    enablement_state     = optional(string, "ENABLED")
    predicate_expression = string
    resource_types       = list(string)
    description          = optional(string)
    recommendation       = optional(string)
    severity             = optional(string, "MEDIUM")
  }))
  default     = {}
  description = "Map of project-level custom modules"
}
