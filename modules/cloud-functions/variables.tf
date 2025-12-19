variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "us-central1"
}

variable "functions" {
  type = map(object({
    name                             = string
    location                         = optional(string)
    description                      = optional(string)
    runtime                          = string
    entry_point                      = string
    source_bucket                    = optional(string)
    source_object                    = optional(string)
    repo_source = optional(object({
      project_id  = optional(string)
      repo_name   = string
      branch_name = optional(string)
      dir         = optional(string)
    }))
    build_environment_variables      = optional(map(string), {})
    max_instance_count               = optional(number, 100)
    min_instance_count               = optional(number, 0)
    available_memory                 = optional(string, "256M")
    timeout_seconds                  = optional(number, 60)
    max_instance_request_concurrency = optional(number, 1)
    available_cpu                    = optional(string, "0.167")
    environment_variables            = optional(map(string), {})
    ingress_settings                 = optional(string, "ALLOW_ALL")
    all_traffic_on_latest_revision   = optional(bool, true)
    service_account_email            = optional(string)
    vpc_connector                    = optional(string)
    vpc_connector_egress_settings    = optional(string)
    secret_environment_variables = optional(list(object({
      key        = string
      project_id = string
      secret     = string
      version    = string
    })))
    event_trigger = optional(object({
      trigger_region        = optional(string)
      event_type            = string
      pubsub_topic          = optional(string)
      service_account_email = optional(string)
      retry_policy          = optional(string, "RETRY_POLICY_DO_NOT_RETRY")
      event_filters = optional(list(object({
        attribute = string
        value     = string
        operator  = optional(string)
      })))
    }))
    labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Cloud Functions to create"
}

variable "function_iam_members" {
  type = map(object({
    function_key = string
    role         = string
    member       = string
  }))
  default     = {}
  description = "IAM members for Cloud Functions"
}
