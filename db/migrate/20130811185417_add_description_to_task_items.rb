class AddDescriptionToTaskItems < ActiveRecord::Migration
  def change
    add_column :task_items, :description, :string
  end
end
