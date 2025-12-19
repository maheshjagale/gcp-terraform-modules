variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "enabled_apis" {
  type = list(string)
  default = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "storage-api.googleapis.com"
  ]
}

variable "create_state_bucket" {
  type    = bool
  default = true
}

variable "state_bucket_name" {
  type = string
}

variable "terraform_sa_name" {
  type    = string
  default = "terraform"
}

variable "terraform_roles" {
  type = list(string)
  default = [
    "roles/editor"
  ]
}

variable "labels" {
  type    = map(string)
  default = {}
}
