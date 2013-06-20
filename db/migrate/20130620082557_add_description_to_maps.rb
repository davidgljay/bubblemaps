class AddDescriptionToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :description, :text
  end
end
