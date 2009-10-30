# == Schema Information
#
# Table name: languages
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  old_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Language < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :communication_on_progresses
  
  default_scope :order => 'name'
end
