class AddTaghashToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :taghash, :text
  end
end
