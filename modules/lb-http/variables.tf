variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "health_check_port" {
  type    = number
  default = 80
}

variable "port_range" {
  type    = string
  default = "80"
}

variable "backends" {
  type = list(object({
    group           = string
    balancing_mode  = string
    max_rate        = number
  }))
  default = []
}
