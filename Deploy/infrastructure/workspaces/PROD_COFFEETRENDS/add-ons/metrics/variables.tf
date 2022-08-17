variable "create_metrics" {
  description = "Installs metrics chart if true"
  type        = bool
  default     = false
}

variable "required_tags" {
  description = "Mandatory tags to be used by the resource"
  type = object({
    Application = string
    Owner       = string
    Environment = string
    ManagedBy   = string
  })
}

variable cluster_host {}
variable certificate_ca {}
variable token {}
variable namespace {}
