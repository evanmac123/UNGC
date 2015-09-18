class Filters::SustainableDevelopmentGoalFilter < Filters::FlatSearchFilter
  def initialize(selected)
    items = SustainableDevelopmentGoal.all.select(:id, :name)
    super(items, selected)
    self.label = 'SDG'
    self.key = 'sustainable_development_goals'
  end

  def options
    # HACK to add a line break after "Goal X:"
    super.map do |option|
      option.name = raw(option.name.split(':').join(":\n"))
      option
    end
  end

end
