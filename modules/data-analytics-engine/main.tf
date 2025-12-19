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

# Dataproc Clusters
resource "google_dataproc_cluster" "clusters" {
  for_each = var.dataproc_clusters

  name    = each.value.name
  project = var.project_id
  region  = each.value.region != null ? each.value.region : var.region

  cluster_config {
    staging_bucket = each.value.staging_bucket

    dynamic "gce_cluster_config" {
      for_each = each.value.gce_config != null ? [each.value.gce_config] : []
      content {
        zone             = gce_cluster_config.value.zone
        network          = gce_cluster_config.value.network
        subnetwork       = gce_cluster_config.value.subnetwork
        service_account  = gce_cluster_config.value.service_account
        tags             = gce_cluster_config.value.tags
        internal_ip_only = gce_cluster_config.value.internal_ip_only
      }
    }

    master_config {
      num_instances = each.value.master_config.num_instances
      machine_type  = each.value.master_config.machine_type

      disk_config {
        boot_disk_type    = each.value.master_config.boot_disk_type
        boot_disk_size_gb = each.value.master_config.boot_disk_size_gb
        num_local_ssds    = each.value.master_config.num_local_ssds
      }
    }

    worker_config {
      num_instances = each.value.worker_config.num_instances
      machine_type  = each.value.worker_config.machine_type

      disk_config {
        boot_disk_type    = each.value.worker_config.boot_disk_type
        boot_disk_size_gb = each.value.worker_config.boot_disk_size_gb
        num_local_ssds    = each.value.worker_config.num_local_ssds
      }
    }

    dynamic "preemptible_worker_config" {
      for_each = each.value.preemptible_worker_config != null ? [each.value.preemptible_worker_config] : []
      content {
        num_instances = preemptible_worker_config.value.num_instances
      }
    }

    software_config {
      image_version       = each.value.image_version
      override_properties = each.value.override_properties
    }

    dynamic "encryption_config" {
      for_each = each.value.kms_key_name != null ? [1] : []
      content {
        kms_key_name = each.value.kms_key_name
      }
    }

    dynamic "autoscaling_config" {
      for_each = each.value.autoscaling_policy != null ? [1] : []
      content {
        policy_uri = each.value.autoscaling_policy
      }
    }
  }

  labels = each.value.labels
}

# Dataflow Jobs
resource "google_dataflow_job" "jobs" {
  for_each = var.dataflow_jobs

  name              = each.value.name
  project           = var.project_id
  region            = each.value.region != null ? each.value.region : var.region
  template_gcs_path = each.value.template_gcs_path
  temp_gcs_location = each.value.temp_gcs_location
  parameters        = each.value.parameters
  machine_type      = each.value.machine_type
  max_workers       = each.value.max_workers
  network           = each.value.network
  subnetwork        = each.value.subnetwork
  service_account_email = each.value.service_account_email
  ip_configuration  = each.value.ip_configuration
  kms_key_name      = each.value.kms_key_name
  enable_streaming_engine = each.value.enable_streaming_engine

  labels = each.value.labels
}

# Composer Environments
resource "google_composer_environment" "environments" {
  for_each = var.composer_environments

  name    = each.value.name
  project = var.project_id
  region  = each.value.region != null ? each.value.region : var.region

  config {
    node_count = each.value.node_count

    dynamic "node_config" {
      for_each = each.value.node_config != null ? [each.value.node_config] : []
      content {
        zone            = node_config.value.zone
        machine_type    = node_config.value.machine_type
        network         = node_config.value.network
        subnetwork      = node_config.value.subnetwork
        service_account = node_config.value.service_account
        tags            = node_config.value.tags
      }
    }

    dynamic "software_config" {
      for_each = each.value.software_config != null ? [each.value.software_config] : []
      content {
        image_version            = software_config.value.image_version
        python_version           = software_config.value.python_version
        airflow_config_overrides = software_config.value.airflow_config_overrides
        pypi_packages            = software_config.value.pypi_packages
        env_variables            = software_config.value.env_variables
      }
    }

    dynamic "private_environment_config" {
      for_each = each.value.private_environment_config != null ? [each.value.private_environment_config] : []
      content {
        enable_private_endpoint    = private_environment_config.value.enable_private_endpoint
        master_ipv4_cidr_block     = private_environment_config.value.master_ipv4_cidr_block
        cloud_sql_ipv4_cidr_block  = private_environment_config.value.cloud_sql_ipv4_cidr_block
        web_server_ipv4_cidr_block = private_environment_config.value.web_server_ipv4_cidr_block
      }
    }

    dynamic "encryption_config" {
      for_each = each.value.kms_key_name != null ? [1] : []
      content {
        kms_key_name = each.value.kms_key_name
      }
    }
  }

  labels = each.value.labels
}

output "dataproc_clusters" {
  value = {
    for k, v in google_dataproc_cluster.clusters : k => {
      id         = v.id
      name       = v.name
      cluster_uuid = v.cluster_uuid
    }
  }
  description = "Dataproc cluster details"
}

output "dataflow_jobs" {
  value = {
    for k, v in google_dataflow_job.jobs : k => {
      id    = v.id
      name  = v.name
      state = v.state
    }
  }
  description = "Dataflow job details"
}

output "composer_environments" {
  value = {
    for k, v in google_composer_environment.environments : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Composer environment details"
}
