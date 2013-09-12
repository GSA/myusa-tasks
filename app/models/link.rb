class Link < ActiveRecord::Base
  belongs_to :task_item

  validates_presence_of :task_item
  validates_presence_of :name
  validates_presence_of :url

end