import tweepy
import config

client = tweepy.Client(bearer_token=config.BEARER_TOKEN)

query = 'coffee -is:retweet'

response = client.search_recent_tweets(query=query, max_results=100, tweet_fields=['created_at', 'lang'], user_fields=['profile_image_url'], expansions=['author_id'])

#print(response)

users = {u['id']: u for u in response.includes['users']}

for tweet in response.data:
    if users[tweet.author_id]:
        user = users[tweet.author_id]
        print(tweet.id)
        print(tweet.lang)