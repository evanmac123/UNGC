class CopAttribute < ActiveRecord::Base
  validates_presence_of :cop_question_id
  belongs_to :cop_question
  
  default_scope :order => 'position'  
end
