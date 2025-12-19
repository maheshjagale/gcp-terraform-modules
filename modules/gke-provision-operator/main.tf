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

resource "google_container_cluster" "gke_operator" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  initial_node_count       = var.initial_node_count
  remove_default_node_pool = true

  network    = var.network_id
  subnetwork = var.subnetwork_id

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  labels = var.labels
}

resource "google_container_node_pool" "operator_pool" {
  name       = "${var.cluster_name}-operator"
  cluster    = google_container_cluster.gke_operator.id
  node_count = var.node_pool_size

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

output "cluster_name" {
  value       = google_container_cluster.gke_operator.name
  description = "Cluster name"
}
