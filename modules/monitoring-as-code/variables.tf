
variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "alert_policies" {
  type = map(object({
    display_name = string
    combiner     = optional(string, "OR")
    enabled      = optional(bool, true)
    conditions = list(object({
      display_name = string
      condition_threshold = optional(object({
        filter          = string
        comparison      = string
        threshold_value = number
        duration        = string
        aggregations = optional(list(object({
          alignment_period     = string
          per_series_aligner   = optional(string)
          cross_series_reducer = optional(string)
          group_by_fields      = optional(list(string))
        })))
        trigger = optional(object({
          count   = optional(number)
          percent = optional(number)
        }))
      }))
      condition_absent = optional(object({
        filter   = string
        duration = string
        aggregations = optional(list(object({
          alignment_period     = string
          per_series_aligner   = optional(string)
          cross_series_reducer = optional(string)
          group_by_fields      = optional(list(string))
        })))
      }))
      condition_matched_log = optional(object({
        filter           = string
        label_extractors = optional(map(string))
      }))
    }))
    notification_channels = optional(list(string), [])
    alert_strategy = optional(object({
      auto_close = optional(string)
      notification_rate_limit = optional(object({
        period = string
      }))
    }))
    documentation = optional(object({
      content   = string
      mime_type = optional(string, "text/markdown")
    }))
    user_labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of alert policies to create"
}

variable "notification_channels" {
  type = map(object({
    display_name = string
    type         = string
    description  = optional(string)
    enabled      = optional(bool, true)
    labels       = optional(map(string), {})
    sensitive_labels = optional(object({
      auth_token  = optional(string)
      password    = optional(string)
      service_key = optional(string)
    }))
    user_labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of notification channels to create"
}

variable "uptime_checks" {
  type = map(object({
    display_name     = string
    timeout          = optional(string, "10s")
    period           = optional(string, "60s")
    checker_type     = optional(string)
    selected_regions = optional(list(string))
    http_check = optional(object({
      path           = optional(string, "/")
      port           = optional(number, 443)
      use_ssl        = optional(bool, true)
      validate_ssl   = optional(bool, true)
      request_method = optional(string, "GET")
      headers        = optional(map(string))
      body           = optional(string)
      content_type   = optional(string)
      accepted_response_status_codes = optional(list(object({
        status_value = optional(number)
        status_class = optional(string)
      })))
    }))
    tcp_check = optional(object({
      port = number
    }))
    monitored_resource = optional(object({
      type   = string
      labels = map(string)
    }))
    content_matchers = optional(list(object({
      content = string
      matcher = optional(string, "CONTAINS_STRING")
    })))
    user_labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of uptime checks to create"
}

variable "dashboards" {
  type = map(object({
    dashboard_json = string
  }))
  default     = {}
  description = "Map of dashboards to create"
}

variable "slos" {
  type = map(object({
    service             = string
    slo_id              = string
    display_name        = string
    goal                = number
    calendar_period     = optional(string)
    rolling_period_days = optional(number)
    basic_sli = optional(object({
      method   = optional(list(string))
      location = optional(list(string))
      version  = optional(list(string))
      availability = optional(object({
        enabled = bool
      }))
      latency = optional(object({
        threshold = string
      }))
    }))
    request_based_sli = optional(object({
      good_total_ratio = optional(object({
        good_service_filter  = optional(string)
        bad_service_filter   = optional(string)
        total_service_filter = optional(string)
      }))
      distribution_cut = optional(object({
        distribution_filter = string
        range_min           = number
        range_max           = number
      }))
    }))
    windows_based_sli = optional(object({
      window_period          = string
      good_bad_metric_filter = optional(string)
      threshold              = number
    }))
    user_labels = optional(map(string), {})
  }))
  default     = {}
  description = "Map of SLOs to create"
}

variable "metric_descriptors" {
  type = map(object({
    description  = string
    display_name = string
    type         = string
    metric_kind  = string
    value_type   = string
    unit         = optional(string)
    labels = optional(list(object({
      key         = string
      value_type  = optional(string, "STRING")
      description = optional(string)
    })))
    launch_stage = optional(string)
  }))
  default     = {}
  description = "Map of custom metric descriptors"
}

variable "monitored_projects" {
  type = map(object({
    metrics_scope = string
    name          = string
  }))
  default     = {}
  description = "Map of monitored projects for cross-project monitoring"
}

variable "groups" {
  type = map(object({
    display_name = string
    filter       = string
    parent_name  = optional(string)
    is_cluster   = optional(bool, false)
  }))
  default     = {}
  description = "Map of monitoring groups"
}
