variable "org_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "constraint" {
  type = string
}

variable "policy_type" {
  type    = string
  default = "boolean"
}

variable "enforced" {
  type    = bool
  default = true
}
