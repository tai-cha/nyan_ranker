require 'twitter'
require 'dotenv'
require 'active_record'
require 'pry'
require 'erb'
require_relative '../app/models/tweet'
require_relative '../app/models/last_tweet'
require_relative '../app/modules/tweet_time'

Dotenv.load './.env' unless ENV['env'] == 'production'

db_config = YAML::load(ERB.new(File.read('config/database.yml')).result)

ActiveRecord::Base.configurations = db_config
ActiveRecord::Base.establish_connection :development

today = Date.today
@time = Time.new(today.year, today.mon, today.day, 22, 22, 0, "+09:00")
@ranking_tweets = Tweet.where('posted_at >= ? AND posted_at < ?', @time - 2.minutes, @time + 2.minutes)

if LastTweet.first&.tweet_id
  @last_tweet_id = LastTweet.first.tweet_id
else
  @last_tweet_id = LastTweet.create(tweet_id: 1220751113864876032)
end

@rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CK']
  config.consumer_secret     = ENV['TWITTER_CS']
  config.access_token        = ENV['TWITTER_TOKEN']
  config.access_token_secret = ENV['TWITTER_SECRET']
end

start_time = Time.now

def send_reply_to(tweet, text)
  return "ツイートが未指定です。" unless tweet
  @rest_client.update(text, in_reply_to_status: tweet)
end

def reply_mentions(tweets)
  tweets.each do |tweet|
    next unless tweet.created_at > (@time + 1.5.minutes)

    top = @ranking_tweets.order(:rank).first
    result = @ranking_tweets.find_by(user_id: tweet.user.id)
    total = @ranking_tweets.count
    unless result
      puts send_reply_to(tweet, "@#{tweet.user.screen_name} ランキング未登録です。")
      next
    end
    diff = result.posted_at - top.posted_at
    if result == top || diff == 0.0
      diff_str = "top"
    else
      diff_str = sprintf("%+#.3f", diff)
    end
    tweet_text = [
        "@#{tweet.user.screen_name}\n",
        "#{tweet.user.name}\n",
        "記録: #{result.posted_at.getlocal("+09:00").strftime("%H:%M:%S.%3N")} (#{diff_str})\n",
        "順位: #{result.rank} / #{total} \n",
        "via: #{result.via.match(/>[\s\S]*?</i).to_s.delete("<>")}\n"
    ].join
    puts send_reply_to(tweet, tweet_text)
    LastTweet.first.update(tweet_id: tweet.id)
  end
end

while start_time + 10.minutes > Time.now
  puts "getting tweets..."
  tweets = @rest_client.mentions_timeline(count: 200, since_id: LastTweet.first.tweet_id)
  reply_mentions tweets
  puts "sleep..."
  sleep 15
end
