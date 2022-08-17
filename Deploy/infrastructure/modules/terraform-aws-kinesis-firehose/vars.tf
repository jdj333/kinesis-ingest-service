variable vpc_id {
  type        = string
  default     = ""
  description = "ID of VPC"
}

variable environment {
  type = string
  default = ""
  description = "Environment Name"
}

variable application {
  type = string
  default = ""
  description = "application Name"
}
