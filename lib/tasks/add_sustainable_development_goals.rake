namespace :db do
  desc "Get the database ready for the redesign"
  task :seed_sustainable_development_goals => :environment do
    create_or_update_seed_sustainable_development_goals
  end

  private

  def create_or_update_seed_sustainable_development_goals
    sdgs = [
      "Goal 1: No Poverty",
      "Goal 2: Zero Hunger",
      "Goal 3: Good Health",
      "Goal 4: Quality Education",
      "Goal 5: Gender Equality",
      "Goal 6: Clean Water and Sanitation",
      "Goal 7: Affordable and Clean Energy",
      "Goal 8: Decent Work and Economic Growth",
      "Goal 9: Industry, Innovation and Infrastructure",
      "Goal 10: Reduced Inequalities",
      "Goal 11: Sustainable Cities and Communities",
      "Goal 12: Responsible Consumption",
      "Goal 13: Climate Action",
      "Goal 14: Life below Water",
      "Goal 15: Life on Land",
      "Goal 16: Peace and Justice",
      "Goal 17: Partnerships for the Goals"
    ]

    sdgs.each do |sdg|
      SustainableDevelopmentGoal.where(name: sdg).first_or_create!
    end
  end
end
