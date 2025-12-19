variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us-central1"
}

variable "org_id" {
  type        = string
  description = "The organization ID"
}

variable "policy_name" {
  type        = string
  description = "The access policy name"
  default     = "default-policy"
}

variable "create_access_policy" {
  type        = bool
  description = "Whether to create a new access policy"
  default     = true
}

variable "access_policy_id" {
  type        = string
  description = "Existing access policy ID (if not creating new)"
  default     = ""
}

variable "access_levels" {
  type = map(object({
    title = string
    basic = optional(object({
      combining_function = optional(string, "AND")
      conditions = list(object({
        ip_subnetworks         = optional(list(string))
        required_access_levels = optional(list(string))
        members                = optional(list(string))
        negate                 = optional(bool)
        regions                = optional(list(string))
        device_policy = optional(object({
          require_screen_lock              = optional(bool)
          require_admin_approval           = optional(bool)
          require_corp_owned               = optional(bool)
          allowed_encryption_statuses      = optional(list(string))
          allowed_device_management_levels = optional(list(string))
        }))
      }))
    }))
  }))
  description = "Map of access levels to create"
  default     = {}
}

variable "service_perimeters" {
  type = map(object({
    title               = string
    perimeter_type      = optional(string)
    restricted_services = list(string)
    resources           = list(string)
    access_levels       = optional(list(string))
    vpc_accessible_services = optional(object({
      enable_restriction = bool
      allowed_services   = list(string)
    }))
    ingress_policies = optional(list(object({
      ingress_from = optional(object({
        identity_type = optional(string)
        identities    = optional(list(string))
      }))
      ingress_to = optional(object({
        resources = optional(list(string))
        operations = optional(list(object({
          service_name = string
          method_selectors = optional(list(object({
            method     = optional(string)
            permission = optional(string)
          })))
        })))
      }))
    })))
    egress_policies = optional(list(object({
      egress_from = optional(object({
        identity_type = optional(string)
        identities    = optional(list(string))
      }))
      egress_to = optional(object({
        resources          = optional(list(string))
        external_resources = optional(list(string))
        operations = optional(list(object({
          service_name = string
          method_selectors = optional(list(object({
            method     = optional(string)
            permission = optional(string)
          })))
        })))
      }))
    })))
  }))
  description = "Map of service perimeters to create"
  default     = {}
}
