variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
}

variable "name" {
  type        = string
  description = "Name prefix for all resources"
}

variable "network" {
  type        = string
  description = "The VPC network self_link"
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork self_link"
}

variable "ip_address" {
  type        = string
  description = "Internal IP address for the forwarding rule"
  default     = null
}

variable "ip_protocol" {
  type        = string
  description = "IP protocol (TCP or UDP)"
  default     = "TCP"
}

variable "ports" {
  type        = list(string)
  description = "List of ports (max 5)"
  default     = ["80"]
}

variable "all_ports" {
  type        = bool
  description = "Whether to forward all ports"
  default     = false
}

variable "protocol" {
  type        = string
  description = "Backend service protocol"
  default     = "TCP"
}

variable "session_affinity" {
  type        = string
  description = "Session affinity type"
  default     = "NONE"
}

variable "timeout_sec" {
  type        = number
  description = "Backend service timeout in seconds"
  default     = 30
}

variable "connection_draining_timeout_sec" {
  type        = number
  description = "Connection draining timeout in seconds"
  default     = 300
}

variable "backends" {
  type = list(object({
    group          = string
    balancing_mode = optional(string)
    failover       = optional(bool)
  }))
  description = "List of backend instance groups"
}

variable "health_check" {
  type = object({
    type                = string
    port                = number
    port_specification  = optional(string)
    request_path        = optional(string)
    host                = optional(string)
    check_interval_sec  = optional(number)
    timeout_sec         = optional(number)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
  })
  description = "Health check configuration"
  default = {
    type                = "TCP"
    port                = 80
    check_interval_sec  = 5
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

variable "health_check_logging" {
  type        = bool
  description = "Whether to enable health check logging"
  default     = true
}

variable "failover_policy" {
  type = object({
    disable_connection_drain_on_failover = optional(bool)
    drop_traffic_if_unhealthy            = optional(bool)
    failover_ratio                       = optional(number)
  })
  description = "Failover policy configuration"
  default     = null
}

variable "log_config" {
  type = object({
    enable      = optional(bool)
    sample_rate = optional(number)
  })
  description = "Logging configuration"
  default     = null
}

variable "allow_global_access" {
  type        = bool
  description = "Whether to allow global access"
  default     = false
}

variable "service_label" {
  type        = string
  description = "Service label for DNS"
  default     = null
}

variable "labels" {
  type        = map(string)
  description = "Labels for the forwarding rule"
  default     = {}
}
