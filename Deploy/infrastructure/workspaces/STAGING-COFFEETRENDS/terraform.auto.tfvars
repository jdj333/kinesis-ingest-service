# EKS configuration

cluster_name = "STAGING-COFFEETRENDS"
environment = "STAGING"

cluster_version = "1.23"

cni_addon_version = "v1.11.2-eksbuild.1"

vpc_name = "STAGING-VPC"
vpc_id = "vpc-0d7b68e9452f4bed8"

private_subnet_ids = ["subnet-0381b9a9cc706499a","subnet-0ef69aea4c43c80bf"]
custom_network_subnet_ids = ["subnet-0375dce34fc93aeb6","subnet-05113b3e9b912919f"]

eks_managed_node_group_default_instance_types = ["m6i.2xlarge"]

eks_managed_node_group_ami_type = "AL2_x86_64"

eks_managed_node_groups_configurations = {
    ingest-service-nodes = {
      min_size     = "2"
      max_size     = "4"
      desired_size = "2"
      instance_types = ["m6i.2xlarge"]
      labels         = {
        node_type = "ingest-service"
      }
       block_device_mappings = {
       xvda = {
        device_name = "/dev/xvda"
        ebs         = {
          volume_size           = 50
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 250
          encrypted             = true
          delete_on_termination = true
         }
        }
       }
    }
}

# Variables for f5 controller
key_name="test"
pool_member_type = "cluster"
log_as3 = true
log_level = "warning"
permissions_boundary = ""