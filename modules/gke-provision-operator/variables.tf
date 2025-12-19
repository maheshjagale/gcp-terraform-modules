variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "initial_node_count" {
  type    = number
  default = 1
}

variable "network_id" {
  type = string
}

variable "subnetwork_id" {
  type = string
}

variable "node_pool_size" {
  type    = number
  default = 3
}

variable "machine_type" {
  type    = string
  default = "e2-standard-4"
}

variable "disk_size_gb" {
  type    = number
  default = 100
}

variable "labels" {
  type    = map(string)
  default = {}
}
