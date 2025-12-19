
variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "us-central1"
}

variable "topics" {
  type = map(object({
    name                       = string
    kms_key_name               = optional(string)
    message_retention_duration = optional(string, "604800s")
    schema_settings = optional(object({
      schema   = string
      encoding = string
    }))
    labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Pub/Sub topics to create"
}

variable "subscriptions" {
  type = map(object({
    name                         = string
    topic_key                    = string
    ack_deadline_seconds         = optional(number, 10)
    message_retention_duration   = optional(string, "604800s")
    retain_acked_messages        = optional(bool, false)
    filter                       = optional(string)
    enable_message_ordering      = optional(bool, false)
    enable_exactly_once_delivery = optional(bool, false)
    expiration_policy_ttl        = optional(string)
    dead_letter_policy = optional(object({
      dead_letter_topic     = string
      max_delivery_attempts = number
    }))
    retry_policy = optional(object({
      minimum_backoff = string
      maximum_backoff = string
    }))
    push_config = optional(object({
      push_endpoint = string
      attributes    = optional(map(string), {})
      oidc_token = optional(object({
        service_account_email = string
        audience              = optional(string)
      }))
    }))
    labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Pub/Sub subscriptions to create"
}

variable "topic_iam_members" {
  type = map(object({
    topic_key = string
    role      = string
    member    = string
  }))
  default     = {}
  description = "IAM members for topics"
}

variable "subscription_iam_members" {
  type = map(object({
    subscription_key = string
    role             = string
    member           = string
  }))
  default     = {}
  description = "IAM members for subscriptions"
}
