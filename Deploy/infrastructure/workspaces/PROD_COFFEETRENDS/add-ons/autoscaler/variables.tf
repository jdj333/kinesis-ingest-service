variable "create_autoscaler" {
  description = "Creates autoscaler if true"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Cluster name of the EKS"
  type        = string
}

variable "autoscaler_namespace" {
  description = "Namescpae for cluster autoscaler"
  type        = string
  default     = "kube-system"
}

variable "autoscaler_service_account_name" {
  description = "Service Account Name "
  type        = string
  default     = "aws-cluster-autoscaler"
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC url of the eks cluster "
  type        = string
}

variable "aws_region" {
  description = "AWS region where the autoscaler should be deployed"
  type        = string
}

variable "permissions_boundary" {
  description = "Permission boundary for creating role"
  type        = string
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
