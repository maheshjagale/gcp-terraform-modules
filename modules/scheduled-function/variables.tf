variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "function_name" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python39"
}

variable "memory_mb" {
  type    = number
  default = 256
}

variable "timeout" {
  type    = number
  default = 60
}

variable "source_bucket" {
  type = string
}

variable "source_object" {
  type = string
}

variable "entry_point" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "schedule_name" {
  type = string
}

variable "schedule_description" {
  type    = string
  default = ""
}

variable "cron_schedule" {
  type = string
}

variable "time_zone" {
  type    = string
  default = "UTC"
}

variable "attempt_deadline" {
  type    = string
  default = "320s"
}

variable "retry_count" {
  type    = number
  default = 1
}
