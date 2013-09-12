class TaskItem < ActiveRecord::Base
  belongs_to :task
  validates_presence_of :task

  has_many :links, inverse_of: :task_item

  validates_presence_of :name

  accepts_nested_attributes_for :links

end
