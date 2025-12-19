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

resource "google_artifact_registry_repository" "repositories" {
  for_each = var.repositories

  location      = each.value.location != null ? each.value.location : var.region
  repository_id = each.value.repository_id
  description   = each.value.description
  format        = each.value.format
  mode          = each.value.mode
  project       = var.project_id

  dynamic "docker_config" {
    for_each = each.value.format == "DOCKER" && each.value.docker_config != null ? [each.value.docker_config] : []
    content {
      immutable_tags = docker_config.value.immutable_tags
    }
  }

  dynamic "maven_config" {
    for_each = each.value.format == "MAVEN" && each.value.maven_config != null ? [each.value.maven_config] : []
    content {
      allow_snapshot_overwrites = maven_config.value.allow_snapshot_overwrites
      version_policy            = maven_config.value.version_policy
    }
  }

  cleanup_policy_dry_run = each.value.cleanup_policy_dry_run

  labels = each.value.labels
}

resource "google_artifact_registry_repository_iam_member" "members" {
  for_each = var.iam_members

  project    = var.project_id
  location   = google_artifact_registry_repository.repositories[each.value.repository_key].location
  repository = google_artifact_registry_repository.repositories[each.value.repository_key].name
  role       = each.value.role
  member     = each.value.member
}

output "repositories" {
  value = {
    for k, v in google_artifact_registry_repository.repositories : k => {
      id   = v.id
      name = v.name
      url  = "${v.location}-docker.pkg.dev/${var.project_id}/${v.repository_id}"
    }
  }
  description = "Artifact Registry repositories"
}

output "repository_ids" {
  value       = { for k, v in google_artifact_registry_repository.repositories : k => v.id }
  description = "Artifact Registry repository IDs"
}
