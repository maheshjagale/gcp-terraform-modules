variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "The GCP zone for the bastion host"
}

variable "name" {
  type        = string
  description = "The name of the bastion host"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
  default     = "dev"
}

variable "machine_type" {
  type        = string
  description = "The machine type for the bastion"
  default     = "e2-micro"
}

variable "image" {
  type        = string
  description = "The boot disk image"
  default     = "debian-cloud/debian-11"
}

variable "disk_size_gb" {
  type        = number
  description = "The boot disk size in GB"
  default     = 20
}

variable "disk_type" {
  type        = string
  description = "The boot disk type"
  default     = "pd-standard"
}

variable "auto_delete_disk" {
  type        = bool
  description = "Whether to auto-delete the boot disk"
  default     = true
}

variable "network" {
  type        = string
  description = "The VPC network"
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork"
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether to assign a public IP"
  default     = false
}

variable "static_ip" {
  type        = string
  description = "Static external IP address (optional)"
  default     = null
}

variable "network_tier" {
  type        = string
  description = "Network tier for the public IP"
  default     = "PREMIUM"
}

variable "tags" {
  type        = list(string)
  description = "Network tags for the instance"
  default     = []
}

variable "labels" {
  type        = map(string)
  description = "Labels for the instance"
  default     = {}
}

variable "create_service_account" {
  type        = bool
  description = "Whether to create a new service account"
  default     = true
}

variable "service_account_email" {
  type        = string
  description = "Existing service account email (if not creating new)"
  default     = ""
}

variable "service_account_scopes" {
  type        = list(string)
  description = "Service account scopes"
  default     = ["cloud-platform"]
}

variable "enable_oslogin" {
  type        = bool
  description = "Whether to enable OS Login"
  default     = true
}

variable "block_project_ssh_keys" {
  type        = bool
  description = "Whether to block project-wide SSH keys"
  default     = true
}

variable "enable_shielded_vm" {
  type        = bool
  description = "Whether to enable Shielded VM features"
  default     = true
}

variable "startup_script" {
  type        = string
  description = "Startup script for the instance"
  default     = ""
}

variable "metadata" {
  type        = map(string)
  description = "Additional metadata for the instance"
  default     = {}
}

variable "preemptible" {
  type        = bool
  description = "Whether the instance is preemptible"
  default     = false
}

variable "automatic_restart" {
  type        = bool
  description = "Whether to automatically restart"
  default     = true
}

variable "on_host_maintenance" {
  type        = string
  description = "Maintenance behavior"
  default     = "MIGRATE"
}

variable "deletion_protection" {
  type        = bool
  description = "Whether to enable deletion protection"
  default     = false
}

variable "create_iap_firewall_rule" {
  type        = bool
  description = "Whether to create IAP SSH firewall rule"
  default     = true
}

variable "host_project_id" {
  type        = string
  description = "Host project ID for Shared VPC (if different from project_id)"
  default     = ""
}
