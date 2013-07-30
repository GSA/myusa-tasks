class Task < ActiveRecord::Base
  has_many :task_items

  validates_presence_of :name
  validates_presence_of :description
end
