
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

resource "google_kms_key_ring" "key_rings" {
  for_each = var.key_rings

  name     = each.value.name
  project  = var.project_id
  location = each.value.location
}

resource "google_kms_crypto_key" "crypto_keys" {
  for_each = var.crypto_keys

  name            = each.value.name
  key_ring        = google_kms_key_ring.key_rings[each.value.key_ring_key].id
  rotation_period = each.value.rotation_period
  purpose         = each.value.purpose

  dynamic "version_template" {
    for_each = each.value.version_template != null ? [each.value.version_template] : []
    content {
      algorithm        = version_template.value.algorithm
      protection_level = version_template.value.protection_level
    }
  }

  destroy_scheduled_duration = each.value.destroy_scheduled_duration
  import_only                = each.value.import_only
  skip_initial_version_creation = each.value.skip_initial_version_creation

  labels = each.value.labels

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key_iam_member" "members" {
  for_each = var.crypto_key_iam_members

  crypto_key_id = google_kms_crypto_key.crypto_keys[each.value.crypto_key_key].id
  role          = each.value.role
  member        = each.value.member
}

resource "google_kms_key_ring_iam_member" "key_ring_members" {
  for_each = var.key_ring_iam_members

  key_ring_id = google_kms_key_ring.key_rings[each.value.key_ring_key].id
  role        = each.value.role
  member      = each.value.member
}

output "key_rings" {
  value = {
    for k, v in google_kms_key_ring.key_rings : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "KMS key ring details"
}

output "crypto_keys" {
  value = {
    for k, v in google_kms_crypto_key.crypto_keys : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "KMS crypto key details"
}

output "crypto_key_ids" {
  value       = { for k, v in google_kms_crypto_key.crypto_keys : k => v.id }
  description = "KMS crypto key IDs"
}
