class AddTaghashToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :taghash, :text
  end
end
