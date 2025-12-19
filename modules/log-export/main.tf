
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

# Project-level Log Sinks
resource "google_logging_project_sink" "project_sinks" {
  for_each = var.project_sinks

  name                   = each.value.name
  project                = var.project_id
  destination            = each.value.destination
  filter                 = each.value.filter
  unique_writer_identity = each.value.unique_writer_identity
  disabled               = each.value.disabled
  description            = each.value.description

  dynamic "bigquery_options" {
    for_each = each.value.bigquery_options != null ? [each.value.bigquery_options] : []
    content {
      use_partitioned_tables = bigquery_options.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions != null ? each.value.exclusions : []
    content {
      name        = exclusions.value.name
      description = exclusions.value.description
      filter      = exclusions.value.filter
      disabled    = exclusions.value.disabled
    }
  }
}

# Folder-level Log Sinks
resource "google_logging_folder_sink" "folder_sinks" {
  for_each = var.folder_sinks

  name             = each.value.name
  folder           = each.value.folder
  destination      = each.value.destination
  filter           = each.value.filter
  include_children = each.value.include_children
  disabled         = each.value.disabled
  description      = each.value.description

  dynamic "bigquery_options" {
    for_each = each.value.bigquery_options != null ? [each.value.bigquery_options] : []
    content {
      use_partitioned_tables = bigquery_options.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions != null ? each.value.exclusions : []
    content {
      name        = exclusions.value.name
      description = exclusions.value.description
      filter      = exclusions.value.filter
      disabled    = exclusions.value.disabled
    }
  }
}

# Organization-level Log Sinks
resource "google_logging_organization_sink" "org_sinks" {
  for_each = var.org_sinks

  name             = each.value.name
  org_id           = each.value.org_id
  destination      = each.value.destination
  filter           = each.value.filter
  include_children = each.value.include_children
  disabled         = each.value.disabled
  description      = each.value.description

  dynamic "bigquery_options" {
    for_each = each.value.bigquery_options != null ? [each.value.bigquery_options] : []
    content {
      use_partitioned_tables = bigquery_options.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions != null ? each.value.exclusions : []
    content {
      name        = exclusions.value.name
      description = exclusions.value.description
      filter      = exclusions.value.filter
      disabled    = exclusions.value.disabled
    }
  }
}

# Log Buckets
resource "google_logging_project_bucket_config" "buckets" {
  for_each = var.log_buckets

  project        = var.project_id
  location       = each.value.location
  bucket_id      = each.value.bucket_id
  description    = each.value.description
  retention_days = each.value.retention_days
  locked         = each.value.locked

  dynamic "cmek_settings" {
    for_each = each.value.kms_key_name != null ? [1] : []
    content {
      kms_key_name = each.value.kms_key_name
    }
  }
}

# Log Metrics
resource "google_logging_metric" "metrics" {
  for_each = var.log_metrics

  name        = each.value.name
  project     = var.project_id
  filter      = each.value.filter
  description = each.value.description
  disabled    = each.value.disabled

  dynamic "metric_descriptor" {
    for_each = each.value.metric_descriptor != null ? [each.value.metric_descriptor] : []
    content {
      metric_kind = metric_descriptor.value.metric_kind
      value_type  = metric_descriptor.value.value_type
      unit        = metric_descriptor.value.unit
      display_name = metric_descriptor.value.display_name

      dynamic "labels" {
        for_each = metric_descriptor.value.labels != null ? metric_descriptor.value.labels : []
        content {
          key         = labels.value.key
          value_type  = labels.value.value_type
          description = labels.value.description
        }
      }
    }
  }

  label_extractors = each.value.label_extractors

  dynamic "bucket_options" {
    for_each = each.value.bucket_options != null ? [each.value.bucket_options] : []
    content {
      dynamic "linear_buckets" {
        for_each = bucket_options.value.linear_buckets != null ? [bucket_options.value.linear_buckets] : []
        content {
          num_finite_buckets = linear_buckets.value.num_finite_buckets
          width              = linear_buckets.value.width
          offset             = linear_buckets.value.offset
        }
      }

      dynamic "exponential_buckets" {
        for_each = bucket_options.value.exponential_buckets != null ? [bucket_options.value.exponential_buckets] : []
        content {
          num_finite_buckets = exponential_buckets.value.num_finite_buckets
          growth_factor      = exponential_buckets.value.growth_factor
          scale              = exponential_buckets.value.scale
        }
      }

      dynamic "explicit_buckets" {
        for_each = bucket_options.value.explicit_buckets != null ? [bucket_options.value.explicit_buckets] : []
        content {
          bounds = explicit_buckets.value.bounds
        }
      }
    }
  }
}

output "project_sinks" {
  value = {
    for k, v in google_logging_project_sink.project_sinks : k => {
      id              = v.id
      name            = v.name
      writer_identity = v.writer_identity
    }
  }
  description = "Project log sink details"
}

output "folder_sinks" {
  value = {
    for k, v in google_logging_folder_sink.folder_sinks : k => {
      id              = v.id
      name            = v.name
      writer_identity = v.writer_identity
    }
  }
  description = "Folder log sink details"
}

output "org_sinks" {
  value = {
    for k, v in google_logging_organization_sink.org_sinks : k => {
      id              = v.id
      name            = v.name
      writer_identity = v.writer_identity
    }
  }
  description = "Organization log sink details"
}

output "log_buckets" {
  value = {
    for k, v in google_logging_project_bucket_config.buckets : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Log bucket details"
}

output "log_metrics" {
  value = {
    for k, v in google_logging_metric.metrics : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Log metric details"
}
