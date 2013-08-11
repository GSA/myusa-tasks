object @task_item

attributes :id, :name, :task_id, :description

child :links do
  attributes :name, :url
end