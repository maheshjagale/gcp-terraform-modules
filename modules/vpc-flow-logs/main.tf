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

# Update existing subnets with flow log configuration
resource "google_compute_subnetwork" "flow_logs" {
  for_each = var.vpc_flow_logs

  name                     = each.value.subnet_name
  project                  = var.project_id
  region                   = each.value.region
  network                  = each.value.network
  ip_cidr_range            = each.value.ip_cidr_range
  private_ip_google_access = each.value.private_ip_google_access

  dynamic "log_config" {
    for_each = each.value.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = each.value.aggregation_interval
      flow_sampling        = each.value.flow_sampling
      metadata             = each.value.metadata
      metadata_fields      = each.value.metadata == "CUSTOM_METADATA" ? each.value.metadata_fields : null
      filter_expr          = each.value.filter_expr
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Log Sink for VPC Flow Logs (optional - to send to BigQuery, Cloud Storage, or Pub/Sub)
resource "google_logging_project_sink" "flow_log_sink" {
  for_each = var.flow_log_sinks

  name                   = each.value.name
  project                = var.project_id
  destination            = each.value.destination
  filter                 = each.value.filter != null ? each.value.filter : "resource.type=\"gce_subnetwork\" AND logName:\"logs/compute.googleapis.com%2Fvpc_flows\""
  unique_writer_identity = each.value.unique_writer_identity

  dynamic "bigquery_options" {
    for_each = each.value.use_partitioned_tables != null ? [1] : []
    content {
      use_partitioned_tables = each.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions != null ? each.value.exclusions : []
    content {
      name        = exclusions.value.name
      description = exclusions.value.description
      filter      = exclusions.value.filter
    }
  }
}

output "subnet_ids" {
  value       = { for k, v in google_compute_subnetwork.flow_logs : k => v.id }
  description = "Subnet IDs with flow logs enabled"
}

output "subnet_self_links" {
  value       = { for k, v in google_compute_subnetwork.flow_logs : k => v.self_link }
  description = "Subnet self links"
}

output "flow_log_sink_ids" {
  value       = { for k, v in google_logging_project_sink.flow_log_sink : k => v.id }
  description = "Flow log sink IDs"
}

output "flow_log_sink_writer_identities" {
  value       = { for k, v in google_logging_project_sink.flow_log_sink : k => v.writer_identity }
  description = "Flow log sink writer identities for IAM binding"
}
