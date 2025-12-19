
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

resource "google_cloud_run_v2_service" "services" {
  for_each = var.services

  name     = each.value.name
  project  = var.project_id
  location = each.value.location != null ? each.value.location : var.region
  ingress  = each.value.ingress

  template {
    revision                = each.value.revision
    service_account         = each.value.service_account
    timeout                 = each.value.timeout
    max_instance_request_concurrency = each.value.max_instance_request_concurrency
    execution_environment   = each.value.execution_environment

    dynamic "scaling" {
      for_each = each.value.scaling != null ? [each.value.scaling] : []
      content {
        min_instance_count = scaling.value.min_instance_count
        max_instance_count = scaling.value.max_instance_count
      }
    }

    dynamic "vpc_access" {
      for_each = each.value.vpc_access != null ? [each.value.vpc_access] : []
      content {
        connector = vpc_access.value.connector
        egress    = vpc_access.value.egress
        
        dynamic "network_interfaces" {
          for_each = vpc_access.value.network_interfaces != null ? vpc_access.value.network_interfaces : []
          content {
            network    = network_interfaces.value.network
            subnetwork = network_interfaces.value.subnetwork
            tags       = network_interfaces.value.tags
          }
        }
      }
    }

    containers {
      name  = each.value.container_name
      image = each.value.image

      dynamic "ports" {
        for_each = each.value.ports != null ? each.value.ports : [{ container_port = 8080 }]
        content {
          name           = lookup(ports.value, "name", null)
          container_port = ports.value.container_port
        }
      }

      dynamic "resources" {
        for_each = each.value.resources != null ? [each.value.resources] : []
        content {
          limits   = resources.value.limits
          cpu_idle = resources.value.cpu_idle
          startup_cpu_boost = resources.value.startup_cpu_boost
        }
      }

      dynamic "env" {
        for_each = each.value.env_vars != null ? each.value.env_vars : []
        content {
          name  = env.value.name
          value = env.value.value

          dynamic "value_source" {
            for_each = env.value.secret_key_ref != null ? [env.value.secret_key_ref] : []
            content {
              secret_key_ref {
                secret  = value_source.value.secret
                version = value_source.value.version
              }
            }
          }
        }
      }

      dynamic "volume_mounts" {
        for_each = each.value.volume_mounts != null ? each.value.volume_mounts : []
        content {
          name       = volume_mounts.value.name
          mount_path = volume_mounts.value.mount_path
        }
      }

      dynamic "startup_probe" {
        for_each = each.value.startup_probe != null ? [each.value.startup_probe] : []
        content {
          initial_delay_seconds = startup_probe.value.initial_delay_seconds
          timeout_seconds       = startup_probe.value.timeout_seconds
          period_seconds        = startup_probe.value.period_seconds
          failure_threshold     = startup_probe.value.failure_threshold

          dynamic "http_get" {
            for_each = startup_probe.value.http_get != null ? [startup_probe.value.http_get] : []
            content {
              path = http_get.value.path
              port = http_get.value.port
            }
          }

          dynamic "tcp_socket" {
            for_each = startup_probe.value.tcp_socket != null ? [startup_probe.value.tcp_socket] : []
            content {
              port = tcp_socket.value.port
            }
          }
        }
      }

      dynamic "liveness_probe" {
        for_each = each.value.liveness_probe != null ? [each.value.liveness_probe] : []
        content {
          initial_delay_seconds = liveness_probe.value.initial_delay_seconds
          timeout_seconds       = liveness_probe.value.timeout_seconds
          period_seconds        = liveness_probe.value.period_seconds
          failure_threshold     = liveness_probe.value.failure_threshold

          dynamic "http_get" {
            for_each = liveness_probe.value.http_get != null ? [liveness_probe.value.http_get] : []
            content {
              path = http_get.value.path
              port = http_get.value.port
            }
          }
        }
      }
    }

    dynamic "volumes" {
      for_each = each.value.volumes != null ? each.value.volumes : []
      content {
        name = volumes.value.name

        dynamic "secret" {
          for_each = volumes.value.secret != null ? [volumes.value.secret] : []
          content {
            secret = secret.value.secret_name

            dynamic "items" {
              for_each = secret.value.items != null ? secret.value.items : []
              content {
                version = items.value.version
                path    = items.value.path
                mode    = items.value.mode
              }
            }
          }
        }

        dynamic "cloud_sql_instance" {
          for_each = volumes.value.cloud_sql_instances != null ? [1] : []
          content {
            instances = volumes.value.cloud_sql_instances
          }
        }
      }
    }

    labels = each.value.template_labels
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = each.value.labels
}

resource "google_cloud_run_v2_service_iam_member" "members" {
  for_each = var.service_iam_members

  project  = var.project_id
  location = google_cloud_run_v2_service.services[each.value.service_key].location
  name     = google_cloud_run_v2_service.services[each.value.service_key].name
  role     = each.value.role
  member   = each.value.member
}

# Cloud Run Jobs
resource "google_cloud_run_v2_job" "jobs" {
  for_each = var.jobs

  name     = each.value.name
  project  = var.project_id
  location = each.value.location != null ? each.value.location : var.region

  template {
    parallelism = each.value.parallelism
    task_count  = each.value.task_count

    template {
      timeout         = each.value.timeout
      service_account = each.value.service_account
      max_retries     = each.value.max_retries

      containers {
        image   = each.value.image
        command = each.value.command
        args    = each.value.args

        dynamic "resources" {
          for_each = each.value.resources != null ? [each.value.resources] : []
          content {
            limits = resources.value.limits
          }
        }

        dynamic "env" {
          for_each = each.value.env_vars != null ? each.value.env_vars : []
          content {
            name  = env.value.name
            value = env.value.value
          }
        }
      }

      dynamic "vpc_access" {
        for_each = each.value.vpc_access != null ? [each.value.vpc_access] : []
        content {
          connector = vpc_access.value.connector
          egress    = vpc_access.value.egress
        }
      }
    }
  }

  labels = each.value.labels
}

output "services" {
  value = {
    for k, v in google_cloud_run_v2_service.services : k => {
      id   = v.id
      name = v.name
      uri  = v.uri
    }
  }
  description = "Cloud Run service details"
}

output "service_urls" {
  value       = { for k, v in google_cloud_run_v2_service.services : k => v.uri }
  description = "Cloud Run service URLs"
}

output "jobs" {
  value = {
    for k, v in google_cloud_run_v2_job.jobs : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Cloud Run job details"
}
