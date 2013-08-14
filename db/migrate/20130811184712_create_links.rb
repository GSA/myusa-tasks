class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :task_item_id
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
