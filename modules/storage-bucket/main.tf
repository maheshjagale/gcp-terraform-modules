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

# Cloud Storage Buckets
resource "google_storage_bucket" "buckets" {
  for_each = var.storage_buckets

  name                        = each.value.name
  project                     = var.project_id
  location                    = each.value.location
  storage_class               = each.value.storage_class
  uniform_bucket_level_access = each.value.uniform_bucket_level_access
  public_access_prevention    = each.value.public_access_prevention
  force_destroy               = each.value.force_destroy
  labels                      = each.value.labels
  requester_pays              = each.value.requester_pays
  default_event_based_hold    = each.value.default_event_based_hold
  enable_object_retention     = each.value.enable_object_retention

  dynamic "versioning" {
    for_each = each.value.versioning_enabled != null ? [1] : []
    content {
      enabled = each.value.versioning_enabled
    }
  }

  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules != null ? each.value.lifecycle_rules : []
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lifecycle_rule.value.action.storage_class
      }
      condition {
        age                        = lifecycle_rule.value.condition.age
        created_before             = lifecycle_rule.value.condition.created_before
        with_state                 = lifecycle_rule.value.condition.with_state
        matches_storage_class      = lifecycle_rule.value.condition.matches_storage_class
        matches_prefix             = lifecycle_rule.value.condition.matches_prefix
        matches_suffix             = lifecycle_rule.value.condition.matches_suffix
        num_newer_versions         = lifecycle_rule.value.condition.num_newer_versions
        days_since_custom_time     = lifecycle_rule.value.condition.days_since_custom_time
        days_since_noncurrent_time = lifecycle_rule.value.condition.days_since_noncurrent_time
        noncurrent_time_before     = lifecycle_rule.value.condition.noncurrent_time_before
      }
    }
  }

  dynamic "retention_policy" {
    for_each = each.value.retention_policy != null ? [each.value.retention_policy] : []
    content {
      retention_period = retention_policy.value.retention_period
      is_locked        = retention_policy.value.is_locked
    }
  }

  dynamic "encryption" {
    for_each = each.value.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = each.value.kms_key_name
    }
  }

  dynamic "website" {
    for_each = each.value.website != null ? [each.value.website] : []
    content {
      main_page_suffix = website.value.main_page_suffix
      not_found_page   = website.value.not_found_page
    }
  }

  dynamic "cors" {
    for_each = each.value.cors_rules != null ? each.value.cors_rules : []
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = cors.value.response_header
      max_age_seconds = cors.value.max_age_seconds
    }
  }

  dynamic "logging" {
    for_each = each.value.logging != null ? [each.value.logging] : []
    content {
      log_bucket        = logging.value.log_bucket
      log_object_prefix = logging.value.log_object_prefix
    }
  }

  dynamic "custom_placement_config" {
    for_each = each.value.custom_placement_config != null ? [each.value.custom_placement_config] : []
    content {
      data_locations = custom_placement_config.value.data_locations
    }
  }

  dynamic "autoclass" {
    for_each = each.value.autoclass != null ? [each.value.autoclass] : []
    content {
      enabled                = autoclass.value.enabled
      terminal_storage_class = autoclass.value.terminal_storage_class
    }
  }

  dynamic "soft_delete_policy" {
    for_each = each.value.soft_delete_retention_seconds != null ? [1] : []
    content {
      retention_duration_seconds = each.value.soft_delete_retention_seconds
    }
  }
}

# Bucket IAM Bindings
resource "google_storage_bucket_iam_member" "bucket_iam" {
  for_each = var.bucket_iam_bindings

  bucket = each.value.bucket
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }

  depends_on = [google_storage_bucket.buckets]
}

# Bucket Objects (optional for initial configuration files)
resource "google_storage_bucket_object" "objects" {
  for_each = var.bucket_objects

  name         = each.value.name
  bucket       = each.value.bucket
  content      = each.value.content
  content_type = each.value.content_type
  source       = each.value.source
  cache_control = each.value.cache_control
  metadata     = each.value.metadata

  depends_on = [google_storage_bucket.buckets]
}

output "bucket_ids" {
  value       = { for k, v in google_storage_bucket.buckets : k => v.id }
  description = "Bucket IDs"
}

output "bucket_names" {
  value       = { for k, v in google_storage_bucket.buckets : k => v.name }
  description = "Bucket names"
}

output "bucket_self_links" {
  value       = { for k, v in google_storage_bucket.buckets : k => v.self_link }
  description = "Bucket self links"
}

output "bucket_urls" {
  value       = { for k, v in google_storage_bucket.buckets : k => v.url }
  description = "Bucket URLs (gs://bucket-name)"
}

output "bucket_locations" {
  value       = { for k, v in google_storage_bucket.buckets : k => v.location }
  description = "Bucket locations"
}

output "bucket_storage_classes" {
  value       = { for k, v in google_storage_bucket.buckets : k => v.storage_class }
  description = "Bucket storage classes"
}

output "object_ids" {
  value       = { for k, v in google_storage_bucket_object.objects : k => v.id }
  description = "Object IDs"
}

output "object_self_links" {
  value       = { for k, v in google_storage_bucket_object.objects : k => v.self_link }
  description = "Object self links"
}
