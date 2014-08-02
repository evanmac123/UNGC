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
#  text             :text             default(""), not null
#

class CopAnswer < ActiveRecord::Base
  belongs_to :communication_on_progress, :foreign_key => :cop_id
  belongs_to :cop_attribute

  scope :by_group, lambda { |group| where("cop_attributes.cop_question_id IN (?)", CopQuestion.group_by(group).map(&:id)).includes(:cop_attribute) }
  scope :by_initiative, lambda { |initiative| where("cop_attributes.cop_question_id IN (?)", CopQuestion.group_by_initiative(initiative).map(&:id)).includes(:cop_attribute) }
  scope :not_covered_by_group, lambda { |group| where("cop_attributes.cop_question_id IN (?) AND value = 0", CopQuestion.group_by(group).map(&:id)).includes(:cop_attribute) }

  def self.cop_questionnaire_answers
    select("cop_answers.id,
                q.implementation,
                q.grouping,
                p.name AS issue_area,
                cop_id,
                o.id as organization_id,
                q.id AS cop_question_id,
                q.position AS question_position,
                q.text AS criterion,
                cop_answers.cop_attribute_id,
                c.position AS best_practice_position,
                c.text AS best_practice,
                cop_answers.value,
                (SELECT CASE cop_answers.value WHEN '1' THEN cop_attribute_id ELSE '' END) AS cop_attribute_id_covered,
                cop.differentiation,
                cop_answers.created_at")
      .joins("JOIN cop_attributes c ON c.id = cop_answers.cop_attribute_id
               LEFT JOIN cop_questions q ON q.id = c.cop_question_id
               LEFT JOIN communication_on_progresses cop ON cop_answers.cop_id = cop.id
               LEFT JOIN organizations o ON o.id = cop.organization_id
               LEFT JOIN principles p ON p.id = q.principle_area_id")
      .where("cop_answers.created_at >= '2011-01-31' AND cop_answers.value IS NOT NULL")
  end

  def cop_attribute_text
    cop_attribute.text
  end

  def open?
    cop_attribute.open?
  end

end
