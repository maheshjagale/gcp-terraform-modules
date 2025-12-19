
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

# Access Policy
resource "google_access_context_manager_access_policy" "policy" {
  count = var.create_access_policy ? 1 : 0

  parent = "organizations/${var.org_id}"
  title  = var.access_policy_title
  scopes = var.access_policy_scopes
}

# Access Levels
resource "google_access_context_manager_access_level" "levels" {
  for_each = var.access_levels

  parent = var.access_policy_name != null ? var.access_policy_name : google_access_context_manager_access_policy.policy[0].name
  name   = "${var.access_policy_name != null ? var.access_policy_name : google_access_context_manager_access_policy.policy[0].name}/accessLevels/${each.value.name}"
  title  = each.value.title
  description = each.value.description

  dynamic "basic" {
    for_each = each.value.basic != null ? [each.value.basic] : []
    content {
      combining_function = basic.value.combining_function

      dynamic "conditions" {
        for_each = basic.value.conditions
        content {
          ip_subnetworks         = conditions.value.ip_subnetworks
          required_access_levels = conditions.value.required_access_levels
          members                = conditions.value.members
          negate                 = conditions.value.negate
          regions                = conditions.value.regions

          dynamic "device_policy" {
            for_each = conditions.value.device_policy != null ? [conditions.value.device_policy] : []
            content {
              require_screen_lock              = device_policy.value.require_screen_lock
              allowed_encryption_statuses      = device_policy.value.allowed_encryption_statuses
              allowed_device_management_levels = device_policy.value.allowed_device_management_levels
              require_admin_approval           = device_policy.value.require_admin_approval
              require_corp_owned               = device_policy.value.require_corp_owned
            }
          }
        }
      }
    }
  }

  dynamic "custom" {
    for_each = each.value.custom != null ? [each.value.custom] : []
    content {
      expr {
        expression  = custom.value.expression
        title       = custom.value.title
        description = custom.value.description
        location    = custom.value.location
      }
    }
  }
}

# Service Perimeters
resource "google_access_context_manager_service_perimeter" "perimeters" {
  for_each = var.service_perimeters

  parent         = var.access_policy_name != null ? var.access_policy_name : google_access_context_manager_access_policy.policy[0].name
  name           = "${var.access_policy_name != null ? var.access_policy_name : google_access_context_manager_access_policy.policy[0].name}/servicePerimeters/${each.value.name}"
  title          = each.value.title
  description    
