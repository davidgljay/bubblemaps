class CreateConfs < ActiveRecord::Migration
  def change
    create_table :confs do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
