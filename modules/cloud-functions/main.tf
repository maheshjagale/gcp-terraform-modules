
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

# Cloud Functions (2nd Gen)
resource "google_cloudfunctions2_function" "functions" {
  for_each = var.functions

  name        = each.value.name
  project     = var.project_id
  location    = each.value.location != null ? each.value.location : var.region
  description = each.value.description

  build_config {
    runtime     = each.value.runtime
    entry_point = each.value.entry_point

    source {
      dynamic "storage_source" {
        for_each = each.value.source_bucket != null ? [1] : []
        content {
          bucket = each.value.source_bucket
          object = each.value.source_object
        }
      }

      dynamic "repo_source" {
        for_each = each.value.repo_source != null ? [each.value.repo_source] : []
        content {
          project_id  = repo_source.value.project_id
          repo_name   = repo_source.value.repo_name
          branch_name = repo_source.value.branch_name
          dir         = repo_source.value.dir
        }
      }
    }

    environment_variables = each.value.build_environment_variables
  }

  service_config {
    max_instance_count             = each.value.max_instance_count
    min_instance_count             = each.value.min_instance_count
    available_memory               = each.value.available_memory
    timeout_seconds                = each.value.timeout_seconds
    max_instance_request_concurrency = each.value.max_instance_request_concurrency
    available_cpu                  = each.value.available_cpu
    environment_variables          = each.value.environment_variables
    ingress_settings               = each.value.ingress_settings
    all_traffic_on_latest_revision = each.value.all_traffic_on_latest_revision
    service_account_email          = each.value.service_account_email
    vpc_connector                  = each.value.vpc_connector
    vpc_connector_egress_settings  = each.value.vpc_connector_egress_settings

    dynamic "secret_environment_variables" {
      for_each = each.value.secret_environment_variables != null ? each.value.secret_environment_variables : []
      content {
        key        = secret_environment_variables.value.key
        project_id = secret_environment_variables.value.project_id
        secret     = secret_environment_variables.value.secret
        version    = secret_environment_variables.value.version
      }
    }
  }

  dynamic "event_trigger" {
    for_each = each.value.event_trigger != null ? [each.value.event_trigger] : []
    content {
      trigger_region        = event_trigger.value.trigger_region
      event_type            = event_trigger.value.event_type
      pubsub_topic          = event_trigger.value.pubsub_topic
      service_account_email = event_trigger.value.service_account_email
      retry_policy          = event_trigger.value.retry_policy

      dynamic "event_filters" {
        for_each = event_trigger.value.event_filters != null ? event_trigger.value.event_filters : []
        content {
          attribute = event_filters.value.attribute
          value     = event_filters.value.value
          operator  = event_filters.value.operator
        }
      }
    }
  }

  labels = each.value.labels
}

# IAM for Cloud Functions
resource "google_cloudfunctions2_function_iam_member" "members" {
  for_each = var.function_iam_members

  project        = var.project_id
  location       = google_cloudfunctions2_function.functions[each.value.function_key].location
  cloud_function = google_cloudfunctions2_function.functions[each.value.function_key].name
  role           = each.value.role
  member         = each.value.member
}

output "functions" {
  value = {
    for k, v in google_cloudfunctions2_function.functions : k => {
      id          = v.id
      name        = v.name
      url         = v.url
      service_config = v.service_config
    }
  }
  description = "Cloud Function details"
}

output "function_urls" {
  value       = { for k, v in google_cloudfunctions2_function.functions : k => v.url }
  description = "Cloud Function URLs"
}
