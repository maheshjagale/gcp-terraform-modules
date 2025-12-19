
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

resource "google_secret_manager_secret" "secrets" {
  for_each = var.secrets

  secret_id = each.value.secret_id
  project   = var.project_id

  dynamic "replication" {
    for_each = each.value.replication_type == "automatic" ? [1] : []
    content {
      auto {}
    }
  }

  dynamic "replication" {
    for_each = each.value.replication_type == "user_managed" ? [1] : []
    content {
      user_managed {
        dynamic "replicas" {
          for_each = each.value.replicas
          content {
            location = replicas.value.location

            dynamic "customer_managed_encryption" {
              for_each = replicas.value.kms_key_name != null ? [1] : []
              content {
                kms_key_name = replicas.value.kms_key_name
              }
            }
          }
        }
      }
    }
  }

  dynamic "rotation" {
    for_each = each.value.rotation != null ? [each.value.rotation] : []
    content {
      next_rotation_time = rotation.value.next_rotation_time
      rotation_period    = rotation.value.rotation_period
    }
  }

  dynamic "topics" {
    for_each = each.value.topics != null ? each.value.topics : []
    content {
      name = topics.value
    }
  }

  expire_time = each.value.expire_time
  ttl         = each.value.ttl
  version_aliases = each.value.version_aliases

  annotations = each.value.annotations
  labels      = each.value.labels
}

resource "google_secret_manager_secret_version" "versions" {
  for_each = var.secret_versions

  secret      = google_secret_manager_secret.secrets[each.value.secret_key].id
  secret_data = each.value.secret_data
  enabled     = each.value.enabled

  deletion_policy = each.value.deletion_policy
}

resource "google_secret_manager_secret_iam_member" "members" {
  for_each = var.secret_iam_members

  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value.secret_key].secret_id
  role      = each.value.role
  member    = each.value.member
}

output "secrets" {
  value = {
    for k, v in google_secret_manager_secret.secrets : k => {
      id        = v.id
      secret_id = v.secret_id
      name      = v.name
    }
  }
  description = "Secret Manager secret details"
}

output "secret_versions" {
  value = {
    for k, v in google_secret_manager_secret_version.versions : k => {
      id      = v.id
      name    = v.name
      version = v.version
    }
  }
  description = "Secret Manager version details"
}

output "secret_ids" {
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.id }
  description = "Secret Manager secret IDs"
}
