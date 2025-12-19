variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "database_version" {
  type    = string
  default = "MYSQL_8_0"
}

variable "instance_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "database_name" {
  type = string
}

variable "availability_type" {
  type    = string
  default = "REGIONAL"
}

variable "require_ssl" {
  type    = bool
  default = true
}

variable "ipv4_enabled" {
  type    = bool
  default = true
}

variable "private_network" {
  type    = string
  default = null
}

variable "create_user" {
  type    = bool
  default = false
}

variable "db_user_name" {
  type    = string
  default = ""
}

variable "db_user_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "labels" {
  type    = map(string)
  default = {}
}
