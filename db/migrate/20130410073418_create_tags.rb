class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :heat1
      t.integer :heat2

      t.timestamps
    end
  end
end
