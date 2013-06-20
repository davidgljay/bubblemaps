class AddDisplayNameToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :display_name, :string
  end
end
