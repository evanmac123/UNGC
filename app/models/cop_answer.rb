# == Schema Information
#
# Table name: cop_answers
#
#  id               :integer          not null, primary key
#  cop_id           :integer
#  cop_attribute_id :integer
#  value            :boolean
#  created_at       :datetime
#  updated_at       :datetime
#  text             :text             not null
#

class CopAnswer < ActiveRecord::Base
  belongs_to :communication_on_progress, :foreign_key => :cop_id
  belongs_to :cop_attribute

  scope :by_group, lambda { |group|
    joins(:cop_attribute)
      .where("cop_attributes.cop_question_id IN (?)", CopQuestion.group_by(group).map(&:id))
      .includes(:cop_attribute)
  }

  scope :by_initiative, lambda { |initiative| where("cop_attributes.cop_question_id IN (?)", CopQuestion.group_by_initiative(initiative).map(&:id)).joins(:cop_attribute) }
  scope :not_covered_by_group, lambda { |group| where("cop_attributes.cop_question_id IN (?) AND value = 0", CopQuestion.group_by(group).map(&:id)).includes(:cop_attribute) }

  def cop_attribute_text
    cop_attribute.text
  end

  def open?
    cop_attribute.open?
  end

end
