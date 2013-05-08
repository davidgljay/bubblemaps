class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.datetime :date
      t.integer :heat1
      t.integer :heat2
      t.text :text

      t.timestamps
    end
  end
end
