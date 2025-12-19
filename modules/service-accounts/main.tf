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

resource "google_service_account" "sa" {
  account_id   = var.service_account_id
  display_name = var.display_name
  project      = var.project_id

  labels = var.labels
}

resource "google_project_iam_member" "sa_roles" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_service_account_key" "sa_key" {
  count              = var.create_key ? 1 : 0
  service_account_id = google_service_account.sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

output "service_account_email" {
  value       = google_service_account.sa.email
  description = "Service account email"
}

output "service_account_name" {
  value       = google_service_account.sa.name
  description = "Service account name"
}

output "service_account_id" {
  value       = google_service_account.sa.unique_id
  description = "Service account ID"
}
