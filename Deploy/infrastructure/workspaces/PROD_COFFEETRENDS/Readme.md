# Install Cluster

* You must have created the user and password for the F5 in AWS secrets manager and put the name of the secret in the variable file terraform.auto.tfvars
* You must have created a key pair in your AWS account and put it in the file terraform.auto.tfvars
* adjust all your other variables and use terraform apply
* this cluster outputs the arn of the policy to be used in the deployment of the helm chart

# Enable Custom Networking
* To enable custom networking you need to run the following script
   * dependencies: brew install jq awscli kubectl
   * ./add-ons/custom-networking/terminateinstances.sh <cluster_name> <region>
   * kubectl -n kube-system set env daemonset aws-node WARM_IP_TARGET=2

# Delete EKS Cluster

* to be able to delete the cluster you must remove the state for all resources created from terraform with helm providers and kubernetes providers. a this time these are the resources:
  * terraform state rm module.efscsi.helm_release.efs_csi[0]
  * terraform state rm module.autoscaler
  * terraform state rm module.autoscaler.helm_release.cluster_autoscaler[0]
  * terraform state rm kubectl_manifest.ENiConfig1
  * terraform state rm kubectl_manifest.ENiConfig2
  * terraform state rm kubectl_manifest.aws-auth
  * helm uninstall cluster-autoscaler -n kube-system
  * delete role cluster autoscaler
  
    
* after that you can use terraform destroy
