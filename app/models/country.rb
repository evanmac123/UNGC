class Country < ActiveRecord::Base
  validates_presence_of :name, :code
  has_and_belongs_to_many :case_stories
end
