import time
import json
import decimal
import boto3
import config

#Connecting to the kinesis stream-need to specify kinesis stream here
kinesis = boto3.client("kinesis")
shard_id = 'shardId-000000000000'
shard_it = kinesis.get_shard_iterator(StreamName=config.STREAM_NAME, ShardId=shard_id, ShardIteratorType="LATEST")["ShardIterator"]

print(shard_it)

#connecting to the dynamoDB table
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(config.DYNAMODB_HASH_TAG_TABLE)

#Parsing the tweets and setting a counter
while 1==1:
    print("Collecting stream data...")
    out = kinesis.get_records(ShardIterator=shard_it, Limit=100)
    for record in out['Records']:
        print("Output Record:")
        print(record['Data'])
        if 'entities' in json.loads(record['Data']):
            htags = json.loads(record['Data'])['entities']['hashtags']
            if htags:
                for ht in htags:
                    htag = ht['text']
                    checkItemExists = table.get_item(
                        Key={
                                'hashtag':htag
                            }
                        )
                if 'Item' in checkItemExists:
                    response = table.update_item(
                        Key={
                            'hashtag': htag 
                        }, #updating the counter if hashtags exists
                        UpdateExpression="set htCount  = htCount + :val",
                        ConditionExpression="attribute_exists(hashtag)",
                        ExpressionAttributeValues={
                            ':val': decimal.Decimal(1) 	
                        },
                        ReturnValues="UPDATED_NEW"
                    )
                else: #not updating the counter if hashtags not exist
                    response = table.update_item(
                            Key={
                                    'hashtag': htag
                            },
                            UpdateExpression="set htCount = :val",
                            ExpressionAttributeValues={
                                    ':val': decimal.Decimal(1)
                            },
                            ReturnValues="UPDATED_NEW"
                    )
    shard_it = out["NextShardIterator"]
    time.sleep(5.0)