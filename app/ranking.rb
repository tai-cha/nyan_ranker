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

@rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CK']
  config.consumer_secret     = ENV['TWITTER_CS']
  config.access_token        = ENV['TWITTER_TOKEN']
  config.access_token_secret = ENV['TWITTER_SECRET']
end


today = Date.today
@time = Time.new(today.year, today.mon, today.day, 22, 22, 0, "+09:00")
@ranking_tweets = Tweet.where('posted_at >= ? AND posted_at < ?', @time - 2.minutes, @time + 2.minutes)

def create_ranking

  tweets_before_nyan = @ranking_tweets.where("posted_at < ?", @time)
  tweets_after_nyan = @ranking_tweets.where("posted_at >= ?", @time)

  tweets_after_nyan.find_each do |t|
    t.update_column(:rank, tweets_after_nyan.where("posted_at < ?", t.posted_at).count + 1)
  end

  latest_tweet_rank = tweets_after_nyan.order(:posted_at).last.rank

  tweets_before_nyan.find_each do |t|
    t.update_column(:rank, latest_tweet_rank + tweets_before_nyan.where("posted_at > ?", t.posted_at).count + 1)
  end
end

def post_ranking
  text = "【にゃ〜んランキング】\n"
  top_tweet = @ranking_tweets.order(:rank).first
  @ranking_tweets.order(:rank).limit(3).each do |tweet|
    diff = tweet.posted_at - top_tweet.posted_at
    if tweet == top_tweet || diff == 0.0
      diff_str = "top"
    else
      puts diff
      diff_str = sprintf("%+#.3f", diff)
    end
    text += "#{tweet.rank}位 #{tweet.posted_at.getlocal("+09:00").strftime("%H:%M:%S.%3N")} (#{diff_str}) #{tweet.screen_name} via:#{tweet.via.match(/>[\s\S]*?</i).to_s.delete("<>")}\n"
  end
  puts text
    @rest_client.update text
end

create_ranking
post_ranking