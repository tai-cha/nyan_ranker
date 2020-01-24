class AddProfileImage < ActiveRecord::Migration[5.2]
  def change
    add_column :tweets, :profile_image, :string
  end
end
