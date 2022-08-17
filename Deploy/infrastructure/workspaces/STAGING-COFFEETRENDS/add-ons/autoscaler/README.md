<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autoscaler_iam_assumable_role_admin"></a> [autoscaler\_iam\_assumable\_role\_admin](#module\_autoscaler\_iam\_assumable\_role\_admin) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 4.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_iam_policy_document.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaler_namespace"></a> [autoscaler\_namespace](#input\_autoscaler\_namespace) | Namescpae for cluster autoscaler | `string` | `"kube-system"` | no |
| <a name="input_autoscaler_service_account_name"></a> [autoscaler\_service\_account\_name](#input\_autoscaler\_service\_account\_name) | Service Account Name | `string` | `"aws-cluster-autoscaler"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the autoscaler should be deployed | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name of the EKS | `string` | n/a | yes |
| <a name="input_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#input\_cluster\_oidc\_issuer\_url) | OIDC url of the eks cluster | `string` | n/a | yes |
| <a name="input_create_autoscaler"></a> [create\_autoscaler](#input\_create\_autoscaler) | Creates autoscaler if true | `bool` | `false` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | Permission boundary for creating role | `string` | n/a | yes |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | Mandatory tags to be used by the resource | <pre>object({<br>    Application = string<br>    Owner       = string<br>    Environment = string<br>    ManagedBy   = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->