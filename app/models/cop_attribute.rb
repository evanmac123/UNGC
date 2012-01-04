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
#  hint            :text            default(""), not null
#

class CopAttribute < ActiveRecord::Base
  validates_presence_of :cop_question_id
  belongs_to :cop_question
  has_many :cop_answers

  default_scope :order => 'cop_attributes.position'
end
