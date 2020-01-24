class CreateLastTweet < ActiveRecord::Migration[5.2]
  def change
    create_table :last_tweets do |t|
      t.bigint :tweet_id

      t.timestamps
    end
  end
end
