object @tasks

attributes :id, :name, :description

child :task_items do
  attributes :id, :name
end