variable "org_id" {
  type = string
}

variable "folders" {
  type = map(object({
    display_name = string
    parent       = string
  }))
  default = {}
}
