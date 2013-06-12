class AddSourceToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :string, :source
  end
end
