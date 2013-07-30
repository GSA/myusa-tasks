FactoryGirl.define do
  factory :task do
    name 'My awesome task'
    description 'A description for my awesome task'

    factory :task_with_task_items do
      after :create do |task|
        task.task_items << FactoryGirl.create(:task_item, name: "Task 1", task_id: task.id)
        task.task_items << FactoryGirl.create(:task_item, name: "Task 2", task_id: task.id)
        task.save
      end
    end

  end
end