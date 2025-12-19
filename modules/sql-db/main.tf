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

resource "google_sql_database_instance" "db" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier                        = var.instance_tier
    availability_type           = var.availability_type
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }
    ip_configuration {
      require_ssl             = var.require_ssl
      private_network         = var.private_network
      ipv4_enabled            = var.ipv4_enabled
      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
  }

  labels = var.labels
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.db.name
  project  = var.project_id
}

resource "google_sql_user" "db_user" {
  count    = var.create_user ? 1 : 0
  name     = var.db_user_name
  instance = google_sql_database_instance.db.name
  password = var.db_user_password
  project  = var.project_id
}

output "instance_name" {
  value       = google_sql_database_instance.db.name
  description = "Instance name"
}

output "instance_connection_name" {
  value       = google_sql_database_instance.db.connection_name
  description = "Connection name"
}

output "private_ip_address" {
  value       = try(google_sql_database_instance.db.private_ip_address, null)
  description = "Private IP address"
}
