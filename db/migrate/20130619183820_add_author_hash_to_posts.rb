class AddAuthorHashToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :authorhash, :text
  end
end
