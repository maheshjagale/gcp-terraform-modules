variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "initial_node_count" {
  description = "Initial node count"
  type        = number
  default     = 3
}

variable "remove_default_node_pool" {
  description = "Remove default node pool"
  type        = bool
  default     = true
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "subnetwork_id" {
  description = "Subnetwork ID"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "Secondary range name for pods"
  type        = string
  default     = "pods"
}

variable "services_secondary_range_name" {
  description = "Secondary range name for services"
  type        = string
  default     = "services"
}

variable "enable_http_load_balancing" {
  description = "Enable HTTP Load Balancing"
  type        = bool
  default     = true
}

variable "enable_horizontal_pod_autoscaling" {
  description = "Enable HPA"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable Network Policy"
  type        = bool
  default     = true
}

variable "create_node_pool" {
  description = "Create node pool"
  type        = bool
  default     = true
}

variable "node_pool_size" {
  description = "Node pool size"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 100
}

variable "labels" {
  description = "Labels"
  type        = map(string)
  default     = {}
}

variable "network_dependency" {
  description = "Network dependency"
  type        = any
  default     = null
}
