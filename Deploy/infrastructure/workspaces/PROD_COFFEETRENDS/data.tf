data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "eks" {
  for_each = toset(var.custom_network_subnet_ids)
  id = each.key
}

output "subnetaz" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = data.aws_subnet.eks[var.custom_network_subnet_ids[0]].availability_zone
}

data "aws_iam_roles" "role" {
  name_regex = "AWSReservedSSO_AdministratorAccess.*"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
  depends_on = [module.eks]
}

data "tls_certificate" "cluster" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

