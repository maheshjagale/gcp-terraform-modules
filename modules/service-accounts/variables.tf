variable "project_id" {
  type = string
}

variable "region" {
  type    = string
}

variable "service_account_id" {
  type = string
}

variable "display_name" {
  type    = string
  default = ""
}

variable "roles" {
  type    = list(string)
  default = []
}

variable "create_key" {
  type    = bool
  default = false
}

variable "labels" {
  type    = map(string)
  default = {}
}
