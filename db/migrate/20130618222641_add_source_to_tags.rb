class AddSourceToTags < ActiveRecord::Migration
  def change
    add_column :tags, :source, :string
  end
end
