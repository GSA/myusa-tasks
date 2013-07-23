object @task

attributes :id, :name

child :task_items do
  attributes :id, :name
end