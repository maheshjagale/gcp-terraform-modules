variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "create_log_sink" {
  type    = bool
  default = false
}

variable "log_sink_name" {
  type    = string
  default = ""
}

variable "log_sink_bucket" {
  type    = string
  default = ""
}

variable "log_filter" {
  type    = string
  default = ""
}

variable "create_alert" {
  type    = bool
  default = false
}

variable "alert_display_name" {
  type    = string
  default = ""
}

variable "alert_combiner" {
  type    = string
  default = "OR"
}

variable "alert_filter" {
  type    = string
  default = ""
}

variable "alert_duration" {
  type    = string
  default = "300s"
}

variable "alert_comparison" {
  type    = string
  default = "COMPARISON_GT"
}

variable "alert_threshold" {
  type    = number
  default = 0
}

variable "notification_channels" {
  type    = list(string)
  default = []
}
