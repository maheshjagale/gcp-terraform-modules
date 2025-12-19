
variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "us-central1"
}

variable "services" {
  type = map(object({
    name                             = string
    location                         = optional(string)
    ingress                          = optional(string, "INGRESS_TRAFFIC_ALL")
    revision                         = optional(string)
    service_account                  = optional(string)
    timeout                          = optional(string, "300s")
    max_instance_request_concurrency = optional(number, 80)
    execution_environment            = optional(string)
    container_name                   = optional(string, "main")
    image                            = string
    scaling = optional(object({
      min_instance_count = optional(number, 0)
      max_instance_count = optional(number, 100)
    }))
    vpc_access = optional(object({
      connector = optional(string)
      egress    = optional(string)
      network_interfaces = optional(list(object({
        network    = string
        subnetwork = string
        tags       = optional(list(string))
      })))
    }))
    ports = optional(list(object({
      name           = optional(string)
      container_port = number
    })))
    resources = optional(object({
      limits            = optional(map(string))
      cpu_idle          = optional(bool, true)
      startup_cpu_boost = optional(bool, false)
    }))
    env_vars = optional(list(object({
      name  = string
      value = optional(string)
      secret_key_ref = optional(object({
        secret  = string
        version = string
      }))
    })))
    volume_mounts = optional(list(object({
      name       = string
      mount_path = string
    })))
    volumes = optional(list(object({
      name = string
      secret = optional(object({
        secret_name = string
        items = optional(list(object({
          version = string
          path    = string
          mode    = optional(number)
        })))
      }))
      cloud_sql_instances = optional(list(string))
    })))
    startup_probe = optional(object({
      initial_delay_seconds = optional(number, 0)
      timeout_seconds       = optional(number, 1)
      period_seconds        = optional(number, 3)
      failure_threshold     = optional(number, 1)
      http_get = optional(object({
        path = string
        port = optional(number, 8080)
      }))
      tcp_socket = optional(object({
        port = number
      }))
    }))
    liveness_probe = optional(object({
      initial_delay_seconds = optional(number, 0)
      timeout_seconds       = optional(number, 1)
      period_seconds        = optional(number, 3)
      failure_threshold     = optional(number, 1)
      http_get = optional(object({
        path = string
        port = optional(number, 8080)
      }))
    }))
    template_labels = optional(map(string), {})
    labels          = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Cloud Run services to create"
}

variable "jobs" {
  type = map(object({
    name            = string
    location        = optional(string)
    image           = string
    parallelism     = optional(number, 1)
    task_count      = optional(number, 1)
    timeout         = optional(string, "600s")
    service_account = optional(string)
    max_retries     = optional(number, 3)
    command         = optional(list(string))
    args            = optional(list(string))
    resources = optional(object({
      limits = map(string)
    }))
    env_vars = optional(list(object({
      name  = string
      value = string
    })))
    vpc_access = optional(object({
      connector = string
      egress    = optional(string)
    }))
    labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Cloud Run jobs to create"
}

variable "service_iam_members" {
  type = map(object({
    service_key = string
    role        = string
    member      = string
  }))
  default     = {}
  description = "IAM members for Cloud Run services"
}
