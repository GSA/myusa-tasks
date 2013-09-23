class Task < ActiveRecord::Base
  has_many :task_items, inverse_of: :task

  validates_presence_of :name
  validates_presence_of :description

  accepts_nested_attributes_for :task_items

end
