variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "dataset_name" {
  type = string
}

variable "fhir_store_name" {
  type = string
}

variable "fhir_version" {
  type    = string
  default = "STU3"
}

variable "time_zone" {
  type    = string
  default = "UTC"
}

variable "labels" {
  type    = map(string)
  default = {}
}
