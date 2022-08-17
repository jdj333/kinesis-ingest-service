variable "cluster_name" {}

variable "cluster_version" {}

variable "vpc_name" {}
variable "environment" {}
variable "private_subnet_ids" {}
variable "custom_network_subnet_ids" {}
variable "vpc_id" {}
variable "eks_managed_node_group_default_instance_types" {}
variable "key_name" {}

variable "eks_managed_node_group_ami_type" {}

variable "eks_managed_node_groups_configurations" {}
variable "cni_addon_version" {}
variable "pool_member_type" {}
variable "log_as3" {}
variable "log_level" {}
variable "permissions_boundary" {
  description = "Permission boundary for creating role"
  type        = string
}
