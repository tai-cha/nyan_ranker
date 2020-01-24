class CreateTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :tweets do |t|
      t.bigint :user_id
      t.string :screen_name
      t.bigint :tweet_id
      t.datetime :posted_at

      t.timestamps
    end
  end
end
