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
  project = var.host_project_id
}

# Enable Shared VPC Host Project
resource "google_compute_shared_vpc_host_project" "host" {
  count   = var.enable_shared_vpc_host ? 1 : 0
  project = var.host_project_id
}

# Attach Service Projects
resource "google_compute_shared_vpc_service_project" "service_projects" {
  for_each = var.service_projects

  host_project    = var.host_project_id
  service_project = each.value.project_id
  deletion_policy = each.value.deletion_policy

  depends_on = [google_compute_shared_vpc_host_project.host]
}

# IAM bindings for Shared VPC subnets
resource "google_compute_subnetwork_iam_member" "subnet_users" {
  for_each = var.subnet_iam_bindings

  project    = var.host_project_id
  region     = each.value.region
  subnetwork = each.value.subnetwork
  role       = each.value.role
  member     = each.value.member
}

# IAM bindings at host project level for network users
resource "google_project_iam_member" "network_users" {
  for_each = var.network_users

  project = var.host_project_id
  role    = each.value.role
  member  = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# Lien to prevent accidental deletion (optional)
resource "google_resource_manager_lien" "shared_vpc_lien" {
  count = var.create_lien ? 1 : 0

  parent       = "projects/${var.host_project_id}"
  restrictions = ["resourcemanager.projects.delete"]
  origin       = "shared-vpc-terraform"
  reason       = "Shared VPC host project - deletion restricted"
}

output "host_project_id" {
  value       = var.host_project_id
  description = "The Shared VPC host project ID"
}

output "host_project_enabled" {
  value       = var.enable_shared_vpc_host ? google_compute_shared_vpc_host_project.host[0].id : null
  description = "The Shared VPC host project resource ID"
}

output "service_project_ids" {
  value       = { for k, v in google_compute_shared_vpc_service_project.service_projects : k => v.service_project }
  description = "Service project IDs attached to the host"
}

output "subnet_iam_bindings" {
  value       = { for k, v in google_compute_subnetwork_iam_member.subnet_users : k => v.id }
  description = "Subnet IAM binding IDs"
}

output "network_user_bindings" {
  value       = { for k, v in google_project_iam_member.network_users : k => v.id }
  description = "Network user IAM binding IDs"
}

output "lien_id" {
  value       = var.create_lien ? google_resource_manager_lien.shared_vpc_lien[0].id : null
  description = "Resource manager lien ID"
}
