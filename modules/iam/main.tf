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
}

resource "google_project_iam_member" "project_roles" {
  for_each = {
    for binding in var.iam_bindings :
    "${binding.role}-${binding.member}" => binding
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

output "iam_bindings" {
  value       = google_project_iam_member.project_roles
  description = "IAM bindings"
}
