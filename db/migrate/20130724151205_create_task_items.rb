class CreateTaskItems < ActiveRecord::Migration
  def change
    create_table :task_items do |t|
      t.string :name
      t.integer :task_id

      t.timestamps
    end
  end
end
