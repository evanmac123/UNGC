class Filters::SustainableDevelopmentGoalFilter < Filters::FlatSearchFilter
  def initialize(selected)
    items = SustainableDevelopmentGoal.all.select(:id, :name)
    super(items, selected)
    self.label = 'SDG'
    self.key = 'sustainable_development_goals'
  end
end
