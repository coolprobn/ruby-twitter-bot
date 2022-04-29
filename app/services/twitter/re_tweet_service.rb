require 'rubygems'
require 'bundler/setup'

require 'twitter'
require 'figaro'
require 'pry-byebug'

Figaro.application = Figaro::Application.new(
  environment: 'production',
  path: File.expand_path('config/application.yml')
)

Figaro.load

module Twitter
  class ReTweetService
    def initialize
      @config = twitter_api_config
      @rest_client = configure_rest_client
    end

    def perform
      stream_client = configure_stream_client

      while true
        puts 'Starting to Retweet 3, 2, 1 ... NOW!'

        fetch_and_store_sensitive_users

        re_tweet(stream_client)
      end
    end

    private

    MAXIMUM_HASHTAG_COUNT = 3
    HASHTAGS_TO_WATCH = %w[#rails #ruby #RubyOnRails]

    attr_reader :config, :rest_client
    attr_accessor :sensitive_user_ids, :last_fetched_on

    def twitter_api_config
      {
        consumer_key: ENV['CONSUMER_KEY'],
        consumer_secret: ENV['CONSUMER_SECRET'],
        access_token: ENV['ACCESS_TOKEN'],
        access_token_secret: ENV['ACCESS_TOKEN_SECRET']
      }
    end

    def configure_rest_client
      puts 'Configuring Rest Client'

      Twitter::REST::Client.new(config)
    end

    def configure_stream_client
      puts 'Configuring Stream Client'

      Twitter::Streaming::Client.new(config)
    end

    def fetch_and_store_sensitive_users
      blocked_user_ids = rest_client.blocked_ids.collect(&:to_i)
      muted_user_ids = rest_client.muted_ids.collect(&:to_i)

      @sensitive_user_ids = [blocked_user_ids, muted_user_ids].flatten.uniq
      @last_fetched_on = Time.now
    end

    def sensitive_users_fetch_time_expired?
      Time.now.hour != last_fetched_on.hour
    end

    def hashtags(tweet)
      tweet_hash = tweet.to_h
      extended_tweet = tweet_hash[:extended_tweet]

      (extended_tweet && extended_tweet[:entities][:hashtags]) || tweet_hash[:entities][:hashtags]
    end

    def tweet?(tweet)
      tweet.is_a?(Twitter::Tweet)
    end

    def retweet?(tweet)
      tweet.retweet?
    end

    def allowed_hashtags?(tweet)
      includes_allowed_hashtags = false

      hashtags(tweet).each do |hashtag|
        if HASHTAGS_TO_WATCH.map(&:upcase).include?("##{hashtag[:text]&.upcase}")
          includes_allowed_hashtags = true

          break
        end
      end

      includes_allowed_hashtags
    end

    def allowed_hashtag_count?(tweet)
      hashtags(tweet)&.count <= MAXIMUM_HASHTAG_COUNT
    end

    def sensitive_tweet?(tweet)
      tweet.possibly_sensitive?
    end

    def from_muted_or_blocked_user?(tweet)
      user_id = tweet.user.id

      sensitive_user_ids.include?(user_id)
    end

    def should_re_tweet?(tweet)
      tweet?(tweet) && !retweet?(tweet) && allowed_hashtag_count?(tweet) && !sensitive_tweet?(tweet) && allowed_hashtags?(tweet) && !from_muted_or_blocked_user?(tweet)
    end

    def re_tweet(stream_client)
      stream_client.filter(:track => HASHTAGS_TO_WATCH.join(',')) do |tweet|
        puts "\nCaught the tweet -> #{tweet.text}"

        fetch_and_store_sensitive_users if sensitive_users_fetch_time_expired?

        if should_re_tweet?(tweet)
          rest_client.retweet tweet

          puts "[#{Time.now}] Retweeted successfully!\n"
        end
      end
    rescue StandardError => e
      puts "=========Error========\n#{e.message}"

      puts "[#{Time.now}] Waiting for 60 seconds ....\n"

      sleep 60
    end
  end
end

Twitter::ReTweetService.new.perform
