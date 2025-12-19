variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "container_image" {
  type    = string
  default = "cos-cloud/cos-stable"
}

variable "boot_disk_size" {
  type    = number
  default = 20
}

variable "network_id" {
  type = string
}

variable "subnetwork_id" {
  type = string
}

variable "container_declaration_file" {
  type = string
}

variable "metadata" {
  type    = map(string)
  default = {}
}

variable "labels" {
  type    = map(string)
  default = {}
}
