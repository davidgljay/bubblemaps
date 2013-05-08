class AddPostcountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :postcount, :integer
  end
end
