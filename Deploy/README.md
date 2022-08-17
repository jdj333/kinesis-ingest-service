### Infrastucture Deployment

#### Setup workspace

 * Navigate to terraform cloud and create the workspace ex: DEV-COFFEETRENDS
 * Set the variable set to the access key and secret key of the AWS account
 * In Settings > General, set the workspace path 

#### Setup EKS Cluster

1. cd ./Deploy/infrastructure/workpaces/DEV-COFFEETRENDS
1. terraform login
1. terraform init
1. terraform 

### Helm Chart Deployment

`cd helm-charts`

`kubectl create ns login-portal`

`kubectl create serviceaccount login-portal-service-account -n login-portal`
    
```
helm install ingest-service twitter-ingest-service \
    --set environment="$ENVIRONMENT" \
    --set image.repository="251414772678.dkr.ecr.us-east-1.amazonaws.com/coffeetrendsusa-ingest-service" \
    --set certificate_arn=arn:aws:acm:us-west-2:070563935692:certificate/430feabd-7dad-4dcc-b093-c156f179ad73 \
    --set domain_fqdn="dev.jamesjenkins.com" \
    --set image.tag="$IMAGE_TAG" \
    --set nodeenv="$NODE_ENV" \
    --set bearer_token="$bearer_token" \
    --set consumer_key="$consumer_key" \
    --set consumer_secret="$consumer_secret" \
    --set access_token_key="$access_token_key" \
    --set access_token_secret="$access_token_secret" \
    --set subnet1="subnet-0375dce34fc93aeb6" \
    --set subnet2="subnet-05113b3e9b912919f" \
    --timeout 1400s
```