import boto3
import json
import config
import os
import tweepy
import time

bearer_token = config.bearer_token
consumer_key = config.consumer_key
consumer_secret = config.consumer_secret
access_token_key = config.access_token_key
access_token_secret = config.access_token_secret

AWS_ACCESS_KEY_ID =  os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY =  os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_DEFAULT_REGION = os.getenv('AWS_DEFAULT_REGION')

HASH_TAG_QUERY = config.HASHTAG
SEARCH_TERM = config.SEARCH_TERM

DeliveryStreamName = config.FIREHOSE_STREAM_NAME

firehoseClient = boto3.client('firehose', 
    region_name=AWS_DEFAULT_REGION,
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY
)

# Doc Reference: https://docs.tweepy.org/en/stable/client.html
twitterClient = tweepy.Client(
    bearer_token=bearer_token, 
    consumer_key=consumer_key,
    consumer_secret=consumer_secret,
    access_token=access_token_key, 
    access_token_secret=access_token_secret,
    wait_on_rate_limit=True # Wait on 503 error? https://developer.twitter.com/en/support/twitter-api/error-troubleshooting
)

twitterAuth = tweepy.OAuth1UserHandler(consumer_key, consumer_secret, access_token_key, access_token_secret)
api = tweepy.API(twitterAuth)

search_terms = [SEARCH_TERM]

class TwitterStream(tweepy.StreamingClient):
    def on_connect(self):
        print("Connected")
    
    def on_tweet(self, tweet):
        if tweet.referenced_tweets == None:
            print(tweet.text)
            #firehoseClient.put_record(DeliveryStreamName=DeliveryStreamName,Record={'Data': json.loads(data)["text"]})
            time.sleep(1)


stream = TwitterStream(bearer_token=bearer_token)

for term in search_terms:
    stream.add_rules(tweepy.StreamRule(term))

stream.filter(tweet_fields=["referenced_tweets"])



# *** OLD CODE ONLY WORKS WITH TWEEPY V3 API ***
# class MyListener(tweepy.Stream):
#     def on_data(self, data):
#         try:
#             with open('python.json', 'a') as f:
#                 f.write(data)
#                 return True
#             #firehoseClient.put_record(DeliveryStreamName=DeliveryStreamName,Record={'Data': json.loads(data)["text"]})
#         except BaseException as e:
#             print("Error on_data: %s" % str(e))
#         return True
 
#     def on_error(self, status):
#         print(status)
#         return True

# twitter_stream = MyListener(
#   consumer_key,
#   consumer_secret,
#   access_token_key,
#   access_token_secret
# )

# twitter_stream.filter(track=[HASH_TAG_QUERY])



# *** OLD CODE ONLY WORKS WITH API v1 and pre tweepy v4 ****
# basic listener that prints received tweets and put them into the stream
# class StdOutListener(Stream):

#     def on_data(self, data):

#         client.put_record(DeliveryStreamName=DeliveryStreamName,Record={'Data': json.loads(data)["text"]})

#         print(json.loads(data)["text"])

#         return True

#     def on_error(self, status):
#         print(status)


# if __name__ == '__main__':

#     #This handles Twitter authetification and the connection to Twitter Streaming API
#     l = StdOutListener()
#     auth = OAuthHandler(consumer_key, consumer_secret)
#     auth.set_access_token(access_token_key, access_token_secret)
#     stream = Stream(auth, l)
#     stream.filter(track=['realmadrid'])