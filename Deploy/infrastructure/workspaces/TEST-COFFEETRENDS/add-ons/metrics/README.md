<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

<vr>
Network should support following communication:
<br>

* Control plane to Metrics Server. Control plane node needs to reach Metrics Server's service/pod IP (or node IP if hostNetwork is enabled) and ports 443 and 4443. Read more about control plane to node communication.
* Metrics Server to Kubelet on all nodes. Metrics server needs to reach node address and Kubelet port. Addresses and ports are configured in Kubelet and published as part of Node object. Addresses in .status.addresses and port in .status.daemonEndpoints.kubeletEndpoint.port field (default 10250). Metrics Server will pick first node address based on the list provided by kubelet-preferred-address-types command line flag (default InternalIP,ExternalIP,Hostname in manifests).

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.metric-server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_metrics"></a> [create\_metrics](#input\_create\_metrics) | Installs metrics chart if true | `bool` | `false` | no |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | Mandatory tags to be used by the resource | <pre>object({<br>    Application = string<br>    Owner       = string<br>    Environment = string<br>    ManagedBy   = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->