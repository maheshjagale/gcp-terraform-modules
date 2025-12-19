
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
}

# Alert Policies
resource "google_monitoring_alert_policy" "alert_policies" {
  for_each = var.alert_policies

  display_name = each.value.display_name
  project      = var.project_id
  combiner     = each.value.combiner
  enabled      = each.value.enabled

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      dynamic "condition_threshold" {
        for_each = conditions.value.condition_threshold != null ? [conditions.value.condition_threshold] : []
        content {
          filter          = condition_threshold.value.filter
          comparison      = condition_threshold.value.comparison
          threshold_value = condition_threshold.value.threshold_value
          duration        = condition_threshold.value.duration

          dynamic "aggregations" {
            for_each = condition_threshold.value.aggregations != null ? condition_threshold.value.aggregations : []
            content {
              alignment_period     = aggregations.value.alignment_period
              per_series_aligner   = aggregations.value.per_series_aligner
              cross_series_reducer = aggregations.value.cross_series_reducer
              group_by_fields      = aggregations.value.group_by_fields
            }
          }

          dynamic "trigger" {
            for_each = condition_threshold.value.trigger != null ? [condition_threshold.value.trigger] : []
            content {
              count   = trigger.value.count
              percent = trigger.value.percent
            }
          }
        }
      }

      dynamic "condition_absent" {
        for_each = conditions.value.condition_absent != null ? [conditions.value.condition_absent] : []
        content {
          filter   = condition_absent.value.filter
          duration = condition_absent.value.duration

          dynamic "aggregations" {
            for_each = condition_absent.value.aggregations != null ? condition_absent.value.aggregations : []
            content {
              alignment_period     = aggregations.value.alignment_period
              per_series_aligner   = aggregations.value.per_series_aligner
              cross_series_reducer = aggregations.value.cross_series_reducer
              group_by_fields      = aggregations.value.group_by_fields
            }
          }
        }
      }

      dynamic "condition_matched_log" {
        for_each = conditions.value.condition_matched_log != null ? [conditions.value.condition_matched_log] : []
        content {
          filter           = condition_matched_log.value.filter
          label_extractors = condition_matched_log.value.label_extractors
        }
      }
    }
  }

  notification_channels = each.value.notification_channels

  dynamic "alert_strategy" {
    for_each = each.value.alert_strategy != null ? [each.value.alert_strategy] : []
    content {
      auto_close = alert_strategy.value.auto_close

      dynamic "notification_rate_limit" {
        for_each = alert_strategy.value.notification_rate_limit != null ? [alert_strategy.value.notification_rate_limit] : []
        content {
          period = notification_rate_limit.value.period
        }
      }
    }
  }

  dynamic "documentation" {
    for_each = each.value.documentation != null ? [each.value.documentation] : []
    content {
      content   = documentation.value.content
      mime_type = documentation.value.mime_type
    }
  }

  user_labels = each.value.user_labels
}

# Notification Channels
resource "google_monitoring_notification_channel" "channels" {
  for_each = var.notification_channels

  display_name = each.value.display_name
  project      = var.project_id
  type         = each.value.type
  description  = each.value.description
  enabled      = each.value.enabled
  labels       = each.value.labels

  dynamic "sensitive_labels" {
    for_each = each.value.sensitive_labels != null ? [each.value.sensitive_labels] : []
    content {
      auth_token  = sensitive_labels.value.auth_token
      password    = sensitive_labels.value.password
      service_key = sensitive_labels.value.service_key
    }
  }

  user_labels = each.value.user_labels
}

# Uptime Checks
resource "google_monitoring_uptime_check_config" "uptime_checks" {
  for_each = var.uptime_checks

  display_name = each.value.display_name
  project      = var.project_id
  timeout      = each.value.timeout
  period       = each.value.period
  checker_type = each.value.checker_type
  selected_regions = each.value.selected_regions

  dynamic "http_check" {
    for_each = each.value.http_check != null ? [each.value.http_check] : []
    content {
      path           = http_check.value.path
      port           = http_check.value.port
      use_ssl        = http_check.value.use_ssl
      validate_ssl   = http_check.value.validate_ssl
      request_method = http_check.value.request_method
      headers        = http_check.value.headers
      body           = http_check.value.body
      content_type   = http_check.value.content_type

      dynamic "accepted_response_status_codes" {
        for_each = http_check.value.accepted_response_status_codes != null ? http_check.value.accepted_response_status_codes : []
        content {
          status_value = accepted_response_status_codes.value.status_value
          status_class = accepted_response_status_codes.value.status_class
        }
      }
    }
  }

  dynamic "tcp_check" {
    for_each = each.value.tcp_check != null ? [each.value.tcp_check] : []
    content {
      port = tcp_check.value.port
    }
  }

  dynamic "monitored_resource" {
    for_each = each.value.monitored_resource != null ? [each.value.monitored_resource] : []
    content {
      type   = monitored_resource.value.type
      labels = monitored_resource.value.labels
    }
  }

  dynamic "content_matchers" {
    for_each = each.value.content_matchers != null ? each.value.content_matchers : []
    content {
      content = content_matchers.value.content
      matcher = content_matchers.value.matcher
    }
  }

  user_labels = each.value.user_labels
}

# Custom Dashboards
resource "google_monitoring_dashboard" "dashboards" {
  for_each = var.dashboards

  project        = var.project_id
  dashboard_json = each.value.dashboard_json
}

# SLOs
resource "google_monitoring_slo" "slos" {
  for_each = var.slos

  service             = each.value.service
  slo_id              = each.value.slo_id
  display_name        = each.value.display_name
  goal                = each.value.goal
  calendar_period     = each.value.calendar_period
  rolling_period_days = each.value.rolling_period_days

  dynamic "basic_sli" {
    for_each = each.value.basic_sli != null ? [each.value.basic_sli] : []
    content {
      method   = basic_sli.value.method
      location = basic_sli.value.location
      version  = basic_sli.value.version

      dynamic "availability" {
        for_each = basic_sli.value.availability != null ? [basic_sli.value.availability] : []
        content {
          enabled = availability.value.enabled
        }
      }

      dynamic "latency" {
        for_each = basic_sli.value.latency != null ? [basic_sli.value.latency] : []
        content {
          threshold = latency.value.threshold
        }
      }
    }
  }

  dynamic "request_based_sli" {
    for_each = each.value.request_based_sli != null ? [each.value.request_based_sli] : []
    content {
      dynamic "good_total_ratio" {
        for_each = request_based_sli.value.good_total_ratio != null ? [request_based_sli.value.good_total_ratio] : []
        content {
          good_service_filter  = good_total_ratio.value.good_service_filter
          bad_service_filter   = good_total_ratio.value.bad_service_filter
          total_service_filter = good_total_ratio.value.total_service_filter
        }
      }

      dynamic "distribution_cut" {
        for_each = request_based_sli.value.distribution_cut != null ? [request_based_sli.value.distribution_cut] : []
        content {
          distribution_filter = distribution_cut.value.distribution_filter
          range {
            min = distribution_cut.value.range_min
            max = distribution_cut.value.range_max
          }
        }
      }
    }
  }

  dynamic "windows_based_sli" {
    for_each = each.value.windows_based_sli != null ? [each.value.windows_based_sli] : []
    content {
      window_period       = windows_based_sli.value.window_period
      good_bad_metric_filter = windows_based_sli.value.good_bad_metric_filter
      good_total_ratio_threshold {
        threshold = windows_based_sli.value.threshold
      }
    }
  }

  user_labels = each.value.user_labels
}

# Metric Descriptors
resource "google_monitoring_metric_descriptor" "descriptors" {
  for_each = var.metric_descriptors

  description  = each.value.description
  display_name = each.value.display_name
  type         = each.value.type
  metric_kind  = each.value.metric_kind
  value_type   = each.value.value_type
  unit         = each.value.unit
  project      = var.project_id

  dynamic "labels" {
    for_each = each.value.labels != null ? each.value.labels : []
    content {
      key         = labels.value.key
      value_type  = labels.value.value_type
      description = labels.value.description
    }
  }

  launch_stage = each.value.launch_stage
}

# Monitored Projects (for cross-project monitoring)
resource "google_monitoring_monitored_project" "monitored_projects" {
  for_each = var.monitored_projects

  metrics_scope = each.value.metrics_scope
  name          = each.value.name
}

# Groups
resource "google_monitoring_group" "groups" {
  for_each = var.groups

  display_name = each.value.display_name
  project      = var.project_id
  filter       = each.value.filter
  parent_name  = each.value.parent_name
  is_cluster   = each.value.is_cluster
}

output "alert_policies" {
  value = {
    for k, v in google_monitoring_alert_policy.alert_policies : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Alert policy details"
}

output "notification_channels" {
  value = {
    for k, v in google_monitoring_notification_channel.channels : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Notification channel details"
}

output "uptime_checks" {
  value = {
    for k, v in google_monitoring_uptime_check_config.uptime_checks : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Uptime check details"
}

output "dashboards" {
  value = {
    for k, v in google_monitoring_dashboard.dashboards : k => {
      id = v.id
    }
  }
  description = "Dashboard details"
}

output "slos" {
  value = {
    for k, v in google_monitoring_slo.slos : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "SLO details"
}

output "groups" {
  value = {
    for k, v in google_monitoring_group.groups : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Group details"
}
