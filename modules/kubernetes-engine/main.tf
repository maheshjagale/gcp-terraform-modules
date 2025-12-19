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

resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  initial_node_count       = var.initial_node_count
  remove_default_node_pool = var.remove_default_node_pool

  network    = var.network_id
  subnetwork = var.subnetwork_id

  addons_config {
    http_load_balancing {
      disabled = !var.enable_http_load_balancing
    }
    horizontal_pod_autoscaling {
      disabled = !var.enable_horizontal_pod_autoscaling
    }
    network_policy_config {
      disabled = !var.enable_network_policy
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  labels = var.labels

  depends_on = [var.network_dependency]
}

resource "google_container_node_pool" "node_pool" {
  count      = var.create_node_pool ? 1 : 0
  name       = "${var.cluster_name}-node-pool"
  cluster    = google_container_cluster.gke.id
  node_count = var.node_pool_size

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb

    labels = var.labels

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

output "cluster_id" {
  value       = google_container_cluster.gke.id
  description = "GKE Cluster ID"
}

output "cluster_name" {
  value       = google_container_cluster.gke.name
  description = "Cluster name"
}

output "endpoint" {
  value       = google_container_cluster.gke.endpoint
  description = "Cluster endpoint"
  sensitive   = true
}
