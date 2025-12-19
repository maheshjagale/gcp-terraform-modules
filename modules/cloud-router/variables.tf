variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "router_name" {
  type = string
}

variable "network_id" {
  type = string
}

variable "bgp_asn" {
  type    = number
  default = 64514
}
