# Ingest Service for Twitter Firehose

This ingest service writes data to a backend data store for downstream application consumption.

![Alt text](Assets/DataStream.png?raw=true "Twitter Data Stream Diagram")

### Set AWS Credentials

When the service is hosted, use a role with a Kinesis policy instead. 
When deploying from your computer you can use aws config profiles or export your credentials in the terminal as demonstrated below.

```
export AWS_ACCESS_KEY_ID="***************"
export AWS_SECRET_ACCESS_KEY="***************"
export AWS_DEFAULT_REGION="us-east-1"
```

Reference:
Firehose to S3 AWS Python Example: 
https://docs.aws.amazon.com/code-samples/latest/catalog/python-kinesis-firehose-firehose_to_s3.py.html

## Option 1: Setup Ingest with Kinesis Firehose

### Step 1: Deploy Terraform EKS

See [Deployment README.md](deploy/README.md)

### Step 2: Build Docker Image and Push to ECR

`docker build -t ingest-service:1`

`docker tag ingest-service:1 251414772678.dkr.ecr.us-east-1.amazonaws.com/coffeetrendsusa-ingest-service:1`

`aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 251414772678.dkr.ecr.us-east-1.amazonaws.com`

`docker push 251414772678.dkr.ecr.us-east-1.amazonaws.com/coffeetrendsusa-ingest-service:1`

### Step 3: Deploy Helm Chart

See [Deployment README.md](deploy/README.md)

## Option 2: Setup Ingest with Kinesis Firehose (Locally)

### Step 1: Install Python Packages

`pip3 install -r requirements.txt`

### Step 2: Run the Ingest Service

`python3 ingest_firehost_stream.py`



## Option 3: Setup Ingest with Kinesis Stream

### Step 1: Create Kinesis Stream

`python3 create_stream.py`

### Step 2: Import Data

`python3 import_data.py`

### Step 3: Output Data

`aws kinesis list-shards --stream-name=twitter_coffee_trends`

`python3 output_data.py`

### Step 4: Create DynamoDB Table

`python3 create_db_table.py`

### Step 5: Store Data into DynamoDB from Kinesis Stream

`python3 ingest_dynamodb.py`