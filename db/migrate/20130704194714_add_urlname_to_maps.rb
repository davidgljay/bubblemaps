class AddUrlnameToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :urlname, :string
  end
end
