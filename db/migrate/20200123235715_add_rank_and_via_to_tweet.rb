class AddRankAndViaToTweet < ActiveRecord::Migration[5.2]
  def change
    add_column :tweets, :rank, :int
    add_column :tweets, :via, :string
  end
end
