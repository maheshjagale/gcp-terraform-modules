
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

# Organization-level Security Center Sources
resource "google_scc_source" "sources" {
  for_each = var.scc_sources

  display_name = each.value.display_name
  organization = each.value.organization
  description  = each.value.description
}

# Notification Configs
resource "google_scc_notification_config" "notification_configs" {
  for_each = var.notification_configs

  config_id    = each.value.config_id
  organization = each.value.organization
  description  = each.value.description
  pubsub_topic = each.value.pubsub_topic

  streaming_config {
    filter = each.value.filter
  }
}

# Mute Configs
resource "google_scc_mute_config" "mute_configs" {
  for_each = var.mute_configs

  mute_config_id = each.value.mute_config_id
  parent         = each.value.parent
  filter         = each.value.filter
  description    = each.value.description
}

# Folder Security Health Analytics Custom Modules
resource "google_scc_folder_custom_module" "folder_custom_modules" {
  for_each = var.folder_custom_modules

  folder       = each.value.folder
  display_name = each.value.display_name
  enablement_state = each.value.enablement_state

  custom_config {
    predicate {
      expression = each.value.predicate_expression
    }
    resource_selector {
      resource_types = each.value.resource_types
    }
    description    = each.value.description
    recommendation = each.value.recommendation
    severity       = each.value.severity
  }
}

# Organization Security Health Analytics Custom Modules
resource "google_scc_organization_custom_module" "org_custom_modules" {
  for_each = var.org_custom_modules

  organization     = each.value.organization
  display_name     = each.value.display_name
  enablement_state = each.value.enablement_state

  custom_config {
    predicate {
      expression = each.value.predicate_expression
    }
    resource_selector {
      resource_types = each.value.resource_types
    }
    description    = each.value.description
    recommendation = each.value.recommendation
    severity       = each.value.severity
  }
}

# Project Security Health Analytics Custom Modules
resource "google_scc_project_custom_module" "project_custom_modules" {
  for_each = var.project_custom_modules

  display_name     = each.value.display_name
  enablement_state = each.value.enablement_state

  custom_config {
    predicate {
      expression = each.value.predicate_expression
    }
    resource_selector {
      resource_types = each.value.resource_types
    }
    description    = each.value.description
    recommendation = each.value.recommendation
    severity       = each.value.severity
  }
}

output "scc_sources" {
  value = {
    for k, v in google_scc_source.sources : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Security Command Center source details"
}

output "notification_configs" {
  value = {
    for k, v in google_scc_notification_config.notification_configs : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "SCC notification config details"
}

output "mute_configs" {
  value = {
    for k, v in google_scc_mute_config.mute_configs : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "SCC mute config details"
}
