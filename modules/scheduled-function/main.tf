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

resource "google_cloudfunctions_function" "scheduled_function" {
  name    = var.function_name
  runtime = var.runtime
  project = var.project_id
  region  = var.region

  available_memory_mb = var.memory_mb
  timeout             = var.timeout

  source_archive_bucket = var.source_bucket
  source_archive_object = var.source_object
  entry_point           = var.entry_point

  service_account_email = var.service_account_email
}

resource "google_cloud_scheduler_job" "job" {
  name             = var.schedule_name
  description      = var.schedule_description
  schedule         = var.cron_schedule
  time_zone        = var.time_zone
  attempt_deadline = var.attempt_deadline
  region           = var.region
  project          = var.project_id

  retry_config {
    retry_count = var.retry_count
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-${var.project_id}.cloudfunctions.net/${var.function_name}"
    oidc_token {
      service_account_email = var.service_account_email
    }
  }
}

output "function_name" {
  value       = google_cloudfunctions_function.scheduled_function.name
  description = "Function name"
}

output "job_name" {
  value       = google_cloud_scheduler_job.job.name
  description = "Scheduler job name"
}
