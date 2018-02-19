# == Schema Information
#
# Table name: cop_attributes
#
#  id              :integer          not null, primary key
#  cop_question_id :integer
#  text            :string(255)
#  position        :integer
#  created_at      :datetime
#  updated_at      :datetime
#  hint            :text(65535)
#  open            :boolean          default(FALSE)
#

class CopAttribute < ActiveRecord::Base
  validates_presence_of :cop_question_id

  belongs_to :cop_question
  has_many :cop_answers

  default_scope { order('cop_attributes.position') }

  scope :sdg_question_with_answer, ->  {
    joins(:cop_answers)
    .where(cop_answers: { value: true } )
    .sdgs
  }

  scope :sdgs, -> { where(text: 'SDG'..'SDGz') }
end
