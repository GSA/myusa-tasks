object @task_item

attributes :id, :name, :task_id

child :links do
  attributes :name, :url
end