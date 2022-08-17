from TwitterAPI import TwitterAPI
import json
import boto3
import config

#accessing the API
api = TwitterAPI(consumer_key=config.consumer_key, consumer_secret=config.consumer_secret, access_token_key=config.access_token_key, access_token_secret=config.access_token_secret, api_version='2')
kinesis = boto3.client('kinesis')

QUERY = config.QUERY

r = api.request('tweets/search/recent', {
    'query':QUERY, 
    'tweet.fields':'author_id',
    'expansions':'author_id'})

for item in r:
    print(item)
    kinesis.put_record(StreamName=config.STREAM_NAME, Data=json.dumps(item), PartitionKey="filler")

print('\nINCLUDES')
print(r.json()['includes'])

print('\nQUOTA')
print(r.get_quota())


# r = api.request('statuses/filter', {'track':'coffeeshop'})

# for item in r:
#     kinesis.put_record(StreamName="twitter_coffee_trends", Data=json.dumps(item), PartitionKey="filler")

#for locations
#r = api.request('statuses/filter', {'locations':'-90,-90,90,90'})
#for userids @abcdef:
#r = api.request('statuses/filter', {'follow':'123456'})
#for general text searches
#r = api.request('statuses/filter', {'track':'iphone'})