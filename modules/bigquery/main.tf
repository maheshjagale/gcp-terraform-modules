
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

resource "google_bigquery_dataset" "datasets" {
  for_each = var.datasets

  dataset_id                 = each.value.dataset_id
  project                    = var.project_id
  friendly_name              = each.value.friendly_name
  description                = each.value.description
  location                   = each.value.location
  delete_contents_on_destroy = each.value.delete_contents_on_destroy
  default_table_expiration_ms = each.value.default_table_expiration_ms

  dynamic "default_encryption_configuration" {
    for_each = each.value.kms_key_name != null ? [1] : []
    content {
      kms_key_name = each.value.kms_key_name
    }
  }

  dynamic "access" {
    for_each = each.value.access
    content {
      role          = access.value.role
      user_by_email = lookup(access.value, "user_by_email", null)
      group_by_email = lookup(access.value, "group_by_email", null)
      special_group = lookup(access.value, "special_group", null)
    }
  }

  labels = each.value.labels
}

resource "google_bigquery_table" "tables" {
  for_each = var.tables

  dataset_id          = google_bigquery_dataset.datasets[each.value.dataset_key].dataset_id
  table_id            = each.value.table_id
  project             = var.project_id
  description         = each.value.description
  deletion_protection = each.value.deletion_protection
  expiration_time     = each.value.expiration_time
  schema              = each.value.schema

  dynamic "time_partitioning" {
    for_each = each.value.time_partitioning != null ? [each.value.time_partitioning] : []
    content {
      type                     = time_partitioning.value.type
      field                    = time_partitioning.value.field
      expiration_ms            = time_partitioning.value.expiration_ms
      require_partition_filter = time_partitioning.value.require_partition_filter
    }
  }

  dynamic "range_partitioning" {
    for_each = each.value.range_partitioning != null ? [each.value.range_partitioning] : []
    content {
      field = range_partitioning.value.field
      range {
        start    = range_partitioning.value.start
        end      = range_partitioning.value.end
        interval = range_partitioning.value.interval
      }
    }
  }

  dynamic "clustering" {
    for_each = each.value.clustering != null ? [1] : []
    content {
      fields = each.value.clustering
    }
  }

  labels = each.value.labels
}

resource "google_bigquery_dataset_iam_member" "members" {
  for_each = var.dataset_iam_members

  project    = var.project_id
  dataset_id = google_bigquery_dataset.datasets[each.value.dataset_key].dataset_id
  role       = each.value.role
  member     = each.value.member
}

output "datasets" {
  value = {
    for k, v in google_bigquery_dataset.datasets : k => {
      id         = v.id
      dataset_id = v.dataset_id
      self_link  = v.self_link
    }
  }
  description = "BigQuery dataset details"
}

output "tables" {
  value = {
    for k, v in google_bigquery_table.tables : k => {
      id       = v.id
      table_id = v.table_id
    }
  }
  description = "BigQuery table details"
}
