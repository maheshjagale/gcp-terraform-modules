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

resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  runtime     = var.runtime
  trigger_topic = var.trigger_topic
  project     = var.project_id
  region      = var.region

  available_memory_mb = var.memory_mb
  timeout             = var.timeout

  source_archive_bucket = var.source_bucket
  source_archive_object = var.source_object
  entry_point           = var.entry_point

  service_account_email = var.service_account_email
}

output "function_name" {
  value       = google_cloudfunctions_function.function.name
  description = "Function name"
}
