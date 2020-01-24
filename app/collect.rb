require 'twitter'
require 'dotenv'
require 'active_record'
require 'pry'
require 'erb'
require_relative '../app/models/tweet'
require_relative '../app/modules/tweet_time'

Dotenv.load './.env' unless ENV['env'] == 'production'

db_config = YAML::load(ERB.new(File.read('config/database.yml')).result)

ActiveRecord::Base.configurations = db_config
ActiveRecord::Base.establish_connection :development

@client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CK']
  config.consumer_secret     = ENV['TWITTER_CS']
  config.access_token        = ENV['TWITTER_TOKEN']
  config.access_token_secret = ENV['TWITTER_SECRET']
end

@rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CK']
  config.consumer_secret     = ENV['TWITTER_CS']
  config.access_token        = ENV['TWITTER_TOKEN']
  config.access_token_secret = ENV['TWITTER_SECRET']
end

@rest_client.update "【稼働テスト #{Time.now.getlocal("+09:00").strftime("%Y%m%d%H%M%S")}】\n にゃ〜ん集計中…"

begin
  @start_time = Time.now
  check_thread = Thread.new do
    loop do
      if Time.now > @start_time + 4.minutes
        puts "4 minutes over...\napp will close."
        exit
      end
      sleep 5
    end
  end

  @client.filter(track: 'にゃ〜ん') do |tweet|
    if tweet.is_a?(Twitter::Tweet)
      begin
        puts "@#{tweet.user.screen_name} #{TweetTime.from(tweet.id)&.getlocal&.iso8601(3)}\n #{tweet.text}"
        Tweet.create(user_id: tweet.user&.id, screen_name: tweet.user&.screen_name, tweet_id: tweet.id, profile_image: tweet.user.profile_image_url_https.to_s, posted_at: TweetTime.from(tweet.id), via: tweet.source)
      rescue => e
      ensure
        binding.pry if ARGV.include?('--debug')
      end
    end
  end
rescue Interrupt
  puts "\nApp has been interrupted. This app close..."
end
