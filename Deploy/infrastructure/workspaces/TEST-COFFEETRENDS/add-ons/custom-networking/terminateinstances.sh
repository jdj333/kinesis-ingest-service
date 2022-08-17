#!/bin/bash
# usage: ./terminateinstances.sh <cluster-name>
# you should terminate the current running instances to be able to work with custom networking
test -n "$1" && echo CLUSTER is "$1" || "echo CLUSTER is not set use terminateinstance.sh <cluster_name> <region> && exit"
test -n "$2" && echo REGION is "$2" || "echo REGION is not set use terminateinstance.sh <cluster_name> <region> && exit"
CLUSTER=$(echo $1)
REGION=$(echo $2)
aws eks update-kubeconfig --name $CLUSTER --region $REGION
kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone
kubectl describe daemonset aws-node -n kube-system | grep -A5 Environment
INSTANCE_IDS=($(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=$CLUSTER" "Name=instance-state-name,Values=running" --region $REGION --output text))
# get target nodes for the cluster
target=$(kubectl get nodes | grep Read | wc -l)

for i in "${INSTANCE_IDS[@]}"
do
echo "Terminating EC2 instance $i ... "
INSTANCE_ID=`echo $i | sed 's/\$//g' |sed 's/\r//g' `
echo this is the instance $INSTANCE_ID
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION | jq -r .TerminatingInstances[0].CurrentState.Name
done
curr=0
while [ $curr -lt $target ]; do
for i in "${INSTANCE_IDS[@]}"
do
    INSTANCE_ID=`echo $i | sed 's/\$//g' |sed 's/\r//g' `
    stat=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --include-all-instances --region $REGION | jq -r .InstanceStatuses[0].InstanceState.Name)
    
    if [ "$stat" == "terminated" ]; then
        sleep 15
        curr=$(kubectl get nodes | grep -v NotReady | grep Read | wc -l)
        kubectl get nodes
        echo "Current Ready nodes = $curr of $target"
    fi
    if [ "$stat" != "terminated" ]; then
        sleep 10
        echo "$i $stat"
    fi
done
done

echo "done"