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

resource "google_organization_policy" "policy" {
  org_id     = var.org_id
  constraint = var.constraint

  dynamic "boolean_policy" {
    for_each = var.policy_type == "boolean" ? [1] : []
    content {
      enforced = var.enforced
    }
  }
}

output "policy_id" {
  value       = google_organization_policy.policy.id
  description = "Policy ID"
}
