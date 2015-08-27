class SustainableDevelopmentGoal < ActiveRecord::Base
  validates_presence_of :name

  def parent?
    false
  end
end
