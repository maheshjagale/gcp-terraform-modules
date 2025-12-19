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

resource "google_logging_project_sink" "log_sink" {
  count           = var.create_log_sink ? 1 : 0
  name            = var.log_sink_name
  destination     = "storage.googleapis.com/${var.log_sink_bucket}"
  filter          = var.log_filter
  unique_writer_identity = true

  project = var.project_id
}

resource "google_monitoring_alert_policy" "alert" {
  count           = var.create_alert ? 1 : 0
  display_name    = var.alert_display_name
  combiner        = var.alert_combiner
  project         = var.project_id

  conditions {
    display_name = "Condition"
    
    condition_threshold {
      filter          = var.alert_filter
      duration        = var.alert_duration
      comparison      = var.alert_comparison
      threshold_value = var.alert_threshold
    }
  }

  notification_channels = var.notification_channels
}

output "log_sink_writer_identity" {
  value       = try(google_logging_project_sink.log_sink[0].writer_identity, null)
  description = "Log sink writer identity"
}
