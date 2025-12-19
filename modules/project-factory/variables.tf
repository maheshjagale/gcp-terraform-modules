variable "org_id" {
  description = "Organization ID"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "GCP Project Name"
  type        = string
}

variable "region" {
  description = "Default region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enabled_apis" {
  description = "List of APIs to enable"
  type        = list(string)
  default     = ["compute.googleapis.com", "container.googleapis.com"]
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
  default     = {}
}
