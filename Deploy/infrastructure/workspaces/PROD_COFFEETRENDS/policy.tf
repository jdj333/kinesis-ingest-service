module "s3_iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "sap-commerce-pods-${var.cluster_name}"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  number_of_role_policy_arns    = 1
  role_policy_arns              = [aws_iam_policy.sap_commerce_pods.arn, "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  #role_permissions_boundary_arn = var.permissions_boundary
  oidc_fully_qualified_subjects = ["system:serviceaccount:sap-commerce:commerce-service-account"]
#   tags                          = var.required_tags
}

resource "aws_iam_policy" "sap_commerce_pods" {
  name_prefix = "sap-commerce-pods"
  description = "EKS sap-commerce-pods policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.sap_commerce_pods.json
}


data "aws_iam_policy_document" "sap_commerce_pods" {
  statement {
    sid    = "sapcommercepolicy"
    effect = "Allow"

    actions = [
        "s3:*",
        "ecr:*",
        "elasticfilesystem:*",
        "dynamodb:*"      
    ]

    resources = ["*"]
  }
}

