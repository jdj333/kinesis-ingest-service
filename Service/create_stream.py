#create the kinesis stream
import boto3
import config

client = boto3.client('kinesis')

response = client.create_stream(
   StreamName=config.STREAM_NAME,
   ShardCount=1
)