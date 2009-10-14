# == Schema Information
#
# Table name: countries
#
#  id           :integer(4)      not null, primary key
#  code         :string(255)
#  name         :string(255)
#  region       :string(255)
#  network_type :integer(4)
#  manager      :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Country < ActiveRecord::Base
  validates_presence_of :name, :code
  has_many :organizations
  has_and_belongs_to_many :case_stories
  has_and_belongs_to_many :communication_on_progresses
  
  default_scope :order => 'name'
end
