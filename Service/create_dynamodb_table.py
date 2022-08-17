import boto3
import config

dynamodb = boto3.resource('dynamodb')

table = dynamodb.create_table(
    TableName=config.DYNAMODB_HASH_TAG_TABLE,
    KeySchema=[
        {
            'AttributeName': 'hashtag',
            'KeyType': 'HASH'
        }
    ],
    AttributeDefinitions=[
        {
            'AttributeName': 'hashtag',
            'AttributeType': 'S'
        }
    ],
    # the pricing isdetermined by Provisioned Throughput, thus it is kept low
    ProvisionedThroughput={
        'ReadCapacityUnits': 5,
        'WriteCapacityUnits': 5
    }
)

table.meta.client.get_waiter('table_exists').wait(TableName=config.DYNAMODB_HASH_TAG_TABLE)