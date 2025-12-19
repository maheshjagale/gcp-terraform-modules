variable "project_id" {
  type = string
}

variable "iam_bindings" {
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}
