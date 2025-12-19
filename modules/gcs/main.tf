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

resource "google_storage_bucket" "buckets" {
  for_each = var.buckets

  name                        = each.value.name
  project                     = var.project_id
  location                    = each.value.location
  storage_class               = each.value.storage_class
  uniform_bucket_level_access = each.value.uniform_bucket_level_access
  force_destroy               = each.value.force_destroy
  public_access_prevention    = each.value.public_access_prevention

  dynamic "versioning" {
    for_each = each.value.versioning_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        created_before        = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }

  dynamic "retention_policy" {
    for_each = each.value.retention_policy != null ? [each.value.retention_policy] : []
    content {
      is_locked        = retention_policy.value.is_locked
      retention_period = retention_policy.value.retention_period
    }
  }

  dynamic "encryption" {
    for_each = each.value.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = each.value.kms_key_name
    }
  }

  dynamic "logging" {
    for_each = each.value.log_bucket != null ? [1] : []
    content {
      log_bucket        = each.value.log_bucket
      log_object_prefix = each.value.log_object_prefix
    }
  }

  labels = each.value.labels
}

resource "google_storage_bucket_iam_member" "members" {
  for_each = var.bucket_iam_members

  bucket = google_storage_bucket.buckets[each.value.bucket_key].name
  role   = each.value.role
  member = each.value.member
}

output "buckets" {
  value = {
    for k, v in google_storage_bucket.buckets : k => {
      name     = v.name
      url      = v.url
      self_link = v.self_link
    }
  }
  description = "GCS bucket details"
}

output "bucket_names" {
  value       = { for k, v in google_storage_bucket.buckets : k => v.name }
  description = "GCS bucket names"
}

output "bucket_urls" {
  value       = { for k, v in google_storage_bucket.buckets : k => v.url }
  description = "GCS bucket URLs"
}
