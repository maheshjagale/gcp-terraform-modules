
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "topics" {
  for_each = var.topics

  name                       = each.value.name
  project                    = var.project_id
  kms_key_name               = each.value.kms_key_name
  message_retention_duration = each.value.message_retention_duration

  dynamic "schema_settings" {
    for_each = each.value.schema_settings != null ? [each.value.schema_settings] : []
    content {
      schema   = schema_settings.value.schema
      encoding = schema_settings.value.encoding
    }
  }

  labels = each.value.labels
}

resource "google_pubsub_subscription" "subscriptions" {
  for_each = var.subscriptions

  name                         = each.value.name
  topic                        = google_pubsub_topic.topics[each.value.topic_key].id
  project                      = var.project_id
  ack_deadline_seconds         = each.value.ack_deadline_seconds
  message_retention_duration   = each.value.message_retention_duration
  retain_acked_messages        = each.value.retain_acked_messages
  filter                       = each.value.filter
  enable_message_ordering      = each.value.enable_message_ordering
  enable_exactly_once_delivery = each.value.enable_exactly_once_delivery

  dynamic "expiration_policy" {
    for_each = each.value.expiration_policy_ttl != null ? [1] : []
    content {
      ttl = each.value.expiration_policy_ttl
    }
  }

  dynamic "dead_letter_policy" {
    for_each = each.value.dead_letter_policy != null ? [each.value.dead_letter_policy] : []
    content {
      dead_letter_topic     = dead_letter_policy.value.dead_letter_topic
      max_delivery_attempts = dead_letter_policy.value.max_delivery_attempts
    }
  }

  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [each.value.retry_policy] : []
    content {
      minimum_backoff = retry_policy.value.minimum_backoff
      maximum_backoff = retry_policy.value.maximum_backoff
    }
  }

  dynamic "push_config" {
    for_each = each.value.push_config != null ? [each.value.push_config] : []
    content {
      push_endpoint = push_config.value.push_endpoint
      attributes    = push_config.value.attributes

      dynamic "oidc_token" {
        for_each = push_config.value.oidc_token != null ? [push_config.value.oidc_token] : []
        content {
          service_account_email = oidc_token.value.service_account_email
          audience              = oidc_token.value.audience
        }
      }
    }
  }

  labels = each.value.labels
}

resource "google_pubsub_topic_iam_member" "topic_members" {
  for_each = var.topic_iam_members

  project = var.project_id
  topic   = google_pubsub_topic.topics[each.value.topic_key].name
  role    = each.value.role
  member  = each.value.member
}

resource "google_pubsub_subscription_iam_member" "subscription_members" {
  for_each = var.subscription_iam_members

  project      = var.project_id
  subscription = google_pubsub_subscription.subscriptions[each.value.subscription_key].name
  role         = each.value.role
  member       = each.value.member
}

output "topics" {
  value = {
    for k, v in google_pubsub_topic.topics : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Pub/Sub topic details"
}

output "subscriptions" {
  value = {
    for k, v in google_pubsub_subscription.subscriptions : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Pub/Sub subscription details"
}
