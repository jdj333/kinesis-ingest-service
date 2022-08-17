 # Security group for remote access to EKS nodes
resource "aws_security_group" "remote_access" {
    name_prefix = "${var.cluster_name}-remote-access"
    description = "Allow remote SSH access"
    vpc_id      = var.vpc_id

    ingress {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

}

# Security group for ALB
resource "aws_security_group" "application_load_balancer" {
    name_prefix = "${var.cluster_name}-alb"
    description = "alb access"
    vpc_id      = var.vpc_id

    ingress {
      description = "Access from my static public ip"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["192.30.201.10/32"]
    }

    ingress {
      description = "Access from my static public ip"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["192.30.201.10/32"]
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

}

module "eks" {
  source = "../../modules/terraform-aws-eks"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      addon_version = var.cni_addon_version
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
    ingress_allow_remote = {
      description = "Allow nodes"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      type        = "ingress"
      cidr_blocks = ["10.0.0.0/8"]
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_allow_node_ports = {
      description = "Allow nodes"
      protocol    = "tcp"
      from_port   = 30000
      to_port     = 32767
      type        = "ingress"
      cidr_blocks = ["10.143.140.0/22"]
    }
  }
# EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = var.eks_managed_node_group_ami_type
    disk_size              = 50
    instance_types         = var.eks_managed_node_group_default_instance_types
    key_name               = var.key_name
  }

  eks_managed_node_groups = var.eks_managed_node_groups_configurations

  tags = {
    Environment = "${var.environment}"
    Terraform   = "true"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })

  # we have to combine the configmap created by the eks module with the externally created node group/profile sub-modules
  aws_auth_configmap_yaml = <<-EOT
  ${chomp(module.eks.aws_auth_configmap_yaml)}
      - groups:
          - system:bootstrappers
          - system:nodes
          - system:masters
        rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${sort(data.aws_iam_roles.role.names)[0]}
        username: ${sort(data.aws_iam_roles.role.names)[0]}
  EOT
}

# yaml resource
resource "kubectl_manifest" "aws-auth" {
    yaml_body = <<-EOT
    ${local.aws_auth_configmap_yaml}
    EOT
}

resource "null_resource" "kubectl" {
       depends_on = [module.eks]
       provisioner "local-exec" {
          command = <<EOH
cat >$HOME/ca1.crt <<EOF
${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}
EOF
cat $HOME/ca1.crt
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
echo "installing kubectl"
mkdir -p $HOME/local/bin
mv ./kubectl $HOME/local/bin/
echo "starting execution"
$HOME/local/bin/kubectl --server="${data.aws_eks_cluster.cluster.endpoint}" --token="${data.aws_eks_cluster_auth.cluster.token}" --certificate_authority=$HOME/ca1.crt set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true;
$HOME/local/bin/kubectl --server="${data.aws_eks_cluster.cluster.endpoint}" --token="${data.aws_eks_cluster_auth.cluster.token}" --certificate_authority=$HOME/ca1.crt set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone
EOH
       }
}
resource "kubectl_manifest" "ENiConfig1" {
    yaml_body = <<-EOT
    apiVersion: crd.k8s.amazonaws.com/v1alpha1
    kind: ENIConfig
    metadata: 
      name: ${data.aws_subnet.eks[var.custom_network_subnet_ids[0]].availability_zone}
    spec: 
      subnet: ${var.custom_network_subnet_ids[0]}
      securityGroups:
         - ${module.eks.node_security_group_id}
    EOT
}

resource "kubectl_manifest" "ENiConfig2" {
    yaml_body = <<-EOT
    apiVersion: crd.k8s.amazonaws.com/v1alpha1
    kind: ENIConfig
    metadata: 
      name: ${data.aws_subnet.eks[var.custom_network_subnet_ids[1]].availability_zone}
    spec: 
      subnet: ${var.custom_network_subnet_ids[1]}
      securityGroups:
         - ${module.eks.node_security_group_id}
    EOT
}

# Below method prints config map aws auth
output "config_map_aws_auth" {
  value = local.aws_auth_configmap_yaml
}

# Below resource generates a local file with the given content
resource "local_file" "aws_cm_auth" {
  filename = "aws-cm-auth-${var.cluster_name}.yaml"
  content  = local.aws_auth_configmap_yaml
}

locals {
  kubeconfig_1 = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks.cluster_endpoint}
    certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${var.cluster_name}"
      #env:
      #  - name: AWS_PROFILE
      #    value: "sbx"
KUBECONFIG
}

# Below method prints the local file kubeconfig
output "kubeconfig" {
  value = local.kubeconfig_1
}

# Below resource generates a local file with the given content
resource "local_file" "kubeconfig" {
  filename   = "config-${var.cluster_name}"
  content    = local.kubeconfig_1
  depends_on = [module.eks]
}

resource "aws_iam_openid_connect_provider" "this" {
  url = module.eks.cluster_oidc_issuer_url 
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
}

module autoscaler {
  source = "./add-ons/autoscaler"
  cluster_name = var.cluster_name
  cluster_host = data.aws_eks_cluster.cluster.endpoint 
  certificate_ca = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  autoscaler_namespace = "kube-system"
  create_autoscaler = true
  autoscaler_service_account_name = "autoscaler-sa"
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  aws_region = data.aws_region.current.name
  permissions_boundary=var.permissions_boundary 
  token = data.aws_eks_cluster_auth.cluster.token
  required_tags= {
    "Application" = "Autoscaler", 
    "Environment" = var.environment, 
    "ManagedBy" = "terraform"
    }

}

