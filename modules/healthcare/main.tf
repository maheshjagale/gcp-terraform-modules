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

resource "google_healthcare_dataset" "dataset" {
  name      = var.dataset_name
  location  = var.region
  project   = var.project_id
  time_zone = var.time_zone
}

resource "google_healthcare_fhir_store" "store" {
  name              = var.fhir_store_name
  dataset           = google_healthcare_dataset.dataset.id
  version           = var.fhir_version
  enable_update_create = true

  labels = var.labels
}

output "dataset_id" {
  value       = google_healthcare_dataset.dataset.id
  description = "Dataset ID"
}

output "fhir_store_id" {
  value       = google_healthcare_fhir_store.store.id
  description = "FHIR store ID"
}
