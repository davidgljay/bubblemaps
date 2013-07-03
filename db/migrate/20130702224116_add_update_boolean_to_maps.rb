class AddUpdateBooleanToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :update_me, :boolean
  end
end
