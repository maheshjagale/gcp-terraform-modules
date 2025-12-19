terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Project Factory Module
module "project_factory" {
  source     = "../modules/project-factory"
  count      = var.module_enabled["project-factory"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Network Module
module "network" {
  source     = "../modules/network"
  count      = var.module_enabled["network"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Kubernetes Engine Module
module "kubernetes_engine" {
  source     = "../modules/kubernetes-engine"
  count      = var.module_enabled["kubernetes-engine"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# VM Module
module "vm" {
  source     = "../modules/vm"
  count      = var.module_enabled["vm"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Service Accounts Module
module "service_accounts" {
  source     = "../modules/service-accounts"
  count      = var.module_enabled["service-accounts"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# SQL DB Module
module "sql_db" {
  source     = "../modules/sql-db"
  count      = var.module_enabled["sql-db"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Bootstrap Module
module "bootstrap" {
  source     = "../modules/bootstrap"
  count      = var.module_enabled["bootstrap"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Folders Module
module "folders" {
  source     = "../modules/folders"
  count      = var.module_enabled["folders"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# LB HTTP Module
module "lb_http" {
  source     = "../modules/lb-http"
  count      = var.module_enabled["lb-http"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# IAM Module
module "iam" {
  source     = "../modules/iam"
  count      = var.module_enabled["iam"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Org Policy Module
module "org_policy" {
  source     = "../modules/org-policy"
  count      = var.module_enabled["org-policy"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Cloud Operations Module
module "cloud_operations" {
  source     = "../modules/cloud-operations"
  count      = var.module_enabled["cloud-operations"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Cloud Router Module
module "cloud_router" {
  source     = "../modules/cloud-router"
  count      = var.module_enabled["cloud-router"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Event Function Module
module "event_function" {
  source     = "../modules/event-function"
  count      = var.module_enabled["event-function"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Scheduled Function Module
module "scheduled_function" {
  source     = "../modules/scheduled-function"
  count      = var.module_enabled["scheduled-function"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Container VM Module
module "container_vm" {
  source     = "../modules/container-vm"
  count      = var.module_enabled["container-vm"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# GKE Provision Operator Module
module "gke_provision_operator" {
  source     = "../modules/gke-provision-operator"
  count      = var.module_enabled["gke-provision-operator"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Healthcare Module
module "healthcare" {
  source     = "../modules/healthcare"
  count      = var.module_enabled["healthcare"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Artifact Registry Module
module "artifact_registry" {
  source     = "../modules/artifact-registry"
  count      = var.module_enabled["artifact-registry"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# GCS Module
module "gcs" {
  source     = "../modules/gcs"
  count      = var.module_enabled["gcs"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# PubSub Module
module "pubsub" {
  source     = "../modules/pubsub"
  count      = var.module_enabled["pubsub"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# BigQuery Module
module "bigquery" {
  source     = "../modules/bigquery"
  count      = var.module_enabled["bigquery"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Data Analytics Engine Module
module "data_analytics_engine" {
  source     = "../modules/data-analytics-engine"
  count      = var.module_enabled["data-analytics-engine"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Memorystore Redis Module
module "memorystore_redis" {
  source     = "../modules/memorystore-redis"
  count      = var.module_enabled["memorystore-redis"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Cloud Functions Module
module "cloud_functions" {
  source     = "../modules/cloud-functions"
  count      = var.module_enabled["cloud-functions"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Cloud Run Module
module "cloud_run" {
  source     = "../modules/cloud-run"
  count      = var.module_enabled["cloud-run"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Log Export Module
module "log_export" {
  source     = "../modules/log-export"
  count      = var.module_enabled["log-export"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# KMS Module
module "kms" {
  source     = "../modules/kms"
  count      = var.module_enabled["kms"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Secrets Manager Module
module "secrets_manager" {
  source     = "../modules/secrets-manager"
  count      = var.module_enabled["secrets-manager"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Security Center Module
module "security_center" {
  source     = "../modules/security-center"
  count      = var.module_enabled["security-center"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Monitoring as Code Module
module "monitoring_as_code" {
  source     = "../modules/monitoring-as-code"
  count      = var.module_enabled["monitoring-as-code"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# VPC SC Module
module "vpc_sc" {
  source     = "../modules/vpc-sc"
  count      = var.module_enabled["vpc-sc"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Address Module
module "address" {
  source     = "../modules/address"
  count      = var.module_enabled["address"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Bastion Host Module
module "bastion_host" {
  source     = "../modules/bastion-host"
  count      = var.module_enabled["bastion-host"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Cloud NAT Module
module "cloud_nat" {
  source     = "../modules/cloud-nat"
  count      = var.module_enabled["cloud-nat"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Firewall Rules Module
module "firewall_rules" {
  source     = "../modules/firewall-rules"
  count      = var.module_enabled["firewall-rules"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Google Cloud Armor Module
module "google_cloud_armor" {
  source     = "../modules/google-cloud-armor"
  count      = var.module_enabled["google-cloud-armor"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# HTTP LB Modules
module "http_lb_modules" {
  source     = "../modules/http-lb-modules"
  count      = var.module_enabled["http-lb-modules"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Internal LB Module
module "internal_lb" {
  source     = "../modules/internal-lb"
  count      = var.module_enabled["internal-lb"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Load Balancer Module
module "load_balancer" {
  source     = "../modules/load-balancer"
  count      = var.module_enabled["load-balancer"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# NAT Instance Module
module "nat_instance" {
  source     = "../modules/nat-instance"
  count      = var.module_enabled["nat-instance"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Network Peering Module
module "network_peering" {
  source     = "../modules/network-peering"
  count      = var.module_enabled["network-peering"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Subnets Module
module "subnets" {
  source     = "../modules/subnets"
  count      = var.module_enabled["subnets"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# VPC Flow Logs Module
module "vpc_flow_logs" {
  source     = "../modules/vpc-flow-logs"
  count      = var.module_enabled["vpc-flow-logs"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# DNS Zone Module
module "dns_zone" {
  source     = "../modules/dns-zone"
  count      = var.module_enabled["dns-zone"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Cloud Router BGP Module
module "cloud_router_bgp" {
  source     = "../modules/cloud-router-bgp"
  count      = var.module_enabled["cloud-router-bgp"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Interconnect Module
module "interconnect" {
  source     = "../modules/interconnect"
  count      = var.module_enabled["interconnect"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Service Networking Module
module "service_networking" {
  source     = "../modules/service-networking"
  count      = var.module_enabled["service-networking"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Shared VPC Host Module
module "shared_vpc_host" {
  source     = "../modules/shared-vpc-host"
  count      = var.module_enabled["shared-vpc-host"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}

# Storage Bucket Module
module "storage_bucket" {
  source     = "../modules/storage-bucket"
  count      = var.module_enabled["storage-bucket"] ? 1 : 0
  project_id = var.project_id
  region     = var.region
  # Add other required variables for this module
}
