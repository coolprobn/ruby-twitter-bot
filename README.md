# ruby-twitter-bot
Twitter bot which retweets #rails and #ruby hashtags (case insensitive). Developed with Ruby.

# Run the bot

1. Install dependencies

   `bundle install`

2. Copy `config/application.yml` from `config/application.yml.sample` and add all required values that you get from Twitter Api configs

3. Run the bot from project root

   `ruby app/services/twitter/re_tweet_service.rb`

4. You can change the hashtags you want the bot to retweet from inside `app/services/twitter/re_tweet_service.rb`

   - Update constant `HASHTAGS_TO_WATCH`

# TODO

1. Allow to update the hashtags from `application.yml`.
2. Add logger and log info and errors to separate file.
