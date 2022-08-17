
module "autoscaler_iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.2.0"
  create_role                   = var.create_autoscaler
  role_name                     = "cluster-autoscaler-${var.cluster_name}"
  provider_url                  = var.cluster_oidc_issuer_url
  number_of_role_policy_arns    = 1
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler[0].arn]
  role_permissions_boundary_arn = var.permissions_boundary
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.autoscaler_namespace}:${var.autoscaler_service_account_name}"]
  tags                          = var.required_tags
}

resource "aws_iam_policy" "cluster_autoscaler" {
  count       = var.create_autoscaler ? 1 : 0
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes",
      "autoscaling:UpdateAutoScalingGroup",
      "eks:DescribeNodegroup"
    ]

    resources = ["*"]
  }
  statement {
    sid = "allowsetdesiredcapacity"
    effect = "Allow"
    actions = [ 
       "autoscaling:SetDesiredCapacity",
       "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    condition {
      test = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}"
      values=["owned"]
    }
    resources = ["*"]
  }

}

############## Autoscaler ##################

resource "helm_release" "cluster_autoscaler" {
  count      = var.create_autoscaler ? 1 : 0
  name       = "cluster-autoscaler"
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  namespace  = var.autoscaler_namespace
  skip_crds  = true
  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "cloudProvider"
    value = "aws"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = var.autoscaler_service_account_name
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.autoscaler_iam_assumable_role_admin.iam_role_arn
  }
  set {
    name  = "awsRegion"
    value = var.aws_region
  }

}
