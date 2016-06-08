# == Schema Information
#
# Table name: sustainable_development_goals
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  goal_number :integer          not null
#

class SustainableDevelopmentGoal < ActiveRecord::Base
  validates_presence_of :name

  def is_parent?
    false
  end
end
