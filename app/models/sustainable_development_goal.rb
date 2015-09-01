class SustainableDevelopmentGoal < ActiveRecord::Base
  validates_presence_of :name

  def is_parent?
    false
  end
end
