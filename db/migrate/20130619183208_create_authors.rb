class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :name
      t.string :screen_name
      t.string :location
      t.string :description
      t.string :profile_image

      t.timestamps
    end
  end
end
