# == Schema Information
#
# Table name: cop_attributes
#
#  id              :integer(4)      not null, primary key
#  cop_question_id :integer(4)
#  text            :string(255)
#  position        :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

class CopAttribute < ActiveRecord::Base
  validates_presence_of :cop_question_id
  belongs_to :cop_question
  
  default_scope :order => 'position'  
end
