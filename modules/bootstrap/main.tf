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

resource "google_project_service" "required_apis" {
  for_each = toset(var.enabled_apis)

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

resource "google_storage_bucket" "terraform_state" {
  count           = var.create_state_bucket ? 1 : 0
  name            = var.state_bucket_name
  location        = var.region
  project         = var.project_id
  force_destroy   = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = var.labels
}

resource "google_service_account" "terraform_sa" {
  account_id   = var.terraform_sa_name
  display_name = "Terraform Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "terraform_permissions" {
  for_each = toset(var.terraform_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

output "state_bucket" {
  value       = try(google_storage_bucket.terraform_state[0].name, null)
  description = "Terraform state bucket"
}

output "terraform_sa_email" {
  value       = google_service_account.terraform_sa.email
  description = "Terraform service account email"
}
