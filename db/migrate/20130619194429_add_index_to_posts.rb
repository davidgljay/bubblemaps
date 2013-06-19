class AddIndexToPosts < ActiveRecord::Migration
  def change
    change_table :posts do |t|
      t.index :source
    end
    change_table :tags do |t|
      t.index :source
    end
  end
end
