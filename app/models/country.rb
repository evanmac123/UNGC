class Country < ActiveRecord::Base
  validates_presence_of :name, :code
  has_and_belongs_to_many :case_stories
  has_and_belongs_to_many :communication_on_progresses
  
  default_scope :order => 'name'
end
