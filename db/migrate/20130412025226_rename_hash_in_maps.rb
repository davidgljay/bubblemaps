class RenameHashInMaps < ActiveRecord::Migration
  def up
    rename_column :maps, :hash, :maphash
  end

  def down
    rename_column :maps, :maphash, :hash
  end
end
