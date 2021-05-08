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

5. Run bot in background

   ```
    # Create a new shell
    $ screen -S twitter-bot

    # run the twitter bot (you should be inside project root)
    $ ruby app/services/twitter/re_tweet_service.rb 
    
    # Detach ruby bot and move to original screen
    $ CTRL + a + d
   ```
   
   Ref: [Run Ruby script in the background](https://stackoverflow.com/a/6391255/9359123)

   **NOTE:** If you have deployed bot to remote server, you need to restart the bot after server restart because it kills the script running in background 

# TODO

1. Allow to update the hashtags from `application.yml`.
2. Create initializer file and add gem require and figaro config to it.
