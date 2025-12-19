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
  project = var.org_id
  region  = var.region
}

resource "google_folder" "environment" {
  display_name = "${var.environment}-folder"
  parent       = "organizations/${var.org_id}"
}

resource "google_google_cloud_project" "project" {
  name       = var.project_name
  project_id = var.project_id
  folder_id  = google_folder.environment.id
  
  labels = merge(
    var.labels,
    {
      environment = var.environment
      managed-by  = "terraform"
    }
  )
}

resource "google_project_service" "required_apis" {
  for_each = toset(var.enabled_apis)

  project = google_google_cloud_project.project.project_id
  service = each.value

  disable_on_destroy = false
}

output "project_id" {
  value       = google_google_cloud_project.project.project_id
  description = "Project ID"
}

output "project_number" {
  value       = google_google_cloud_project.project.number
  description = "Project Number"
}

output "folder_id" {
  value       = google_folder.environment.id
  description = "Folder ID"
}
