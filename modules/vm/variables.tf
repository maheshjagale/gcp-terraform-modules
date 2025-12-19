variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "instance_name" {
  description = "Instance name"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-medium"
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "subnetwork_id" {
  description = "Subnetwork ID"
  type        = string
}

variable "create_public_ip" {
  description = "Create public IP"
  type        = bool
  default     = false
}

variable "static_ip" {
  description = "Static IP address"
  type        = string
  default     = null
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "Service account scopes"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "metadata" {
  description = "Metadata"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Network tags"
  type        = list(string)
  default     = []
}
