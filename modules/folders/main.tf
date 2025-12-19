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
  org_id = var.org_id
}

resource "google_folder" "folders" {
  for_each = var.folders

  display_name = each.value.display_name
  parent       = each.value.parent
}

output "folders" {
  value       = { for k, v in google_folder.folders : k => v.id }
  description = "Folder IDs"
}
