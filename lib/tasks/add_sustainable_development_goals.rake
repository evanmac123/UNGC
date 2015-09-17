namespace :db do
  desc "Get the database ready for the redesign"
  task :seed_sustainable_development_goals => :environment do
    create_or_update_seed_sustainable_development_goals
  end

  private

  def create_or_update_seed_sustainable_development_goals
    sdgs = [
      {goal: 1, name: "Goal 1: No Poverty"},
      {goal: 2, name: "Goal 2: Zero Hunger"},
      {goal: 3, name: "Goal 3: Good Health and Well-Being"},
      {goal: 4, name: "Goal 4: Quality Education"},
      {goal: 5, name: "Goal 5: Gender Equality"},
      {goal: 6, name: "Goal 6: Clean Water and Sanitation"},
      {goal: 7, name: "Goal 7: Affordable and Clean Energy"},
      {goal: 8, name: "Goal 8: Decent Work and Economic Growth"},
      {goal: 9, name: "Goal 9: Industry, Innovation and Infrastructure"},
      {goal: 10, name: "Goal 10: Reduced Inequalities"},
      {goal: 11, name: "Goal 11: Sustainable Cities and Communities"},
      {goal: 12, name: "Goal 12: Responsible Consumption and Production"},
      {goal: 13, name: "Goal 13: Climate Action"},
      {goal: 14, name: "Goal 14: Life below Water"},
      {goal: 15, name: "Goal 15: Life on Land"},
      {goal: 16, name: "Goal 16: Peace, Justice and Strong Institutions"},
      {goal: 17, name: "Goal 17: Partnerships for the Goals"}
    ]

    sdgs.each do |sdg|
      s = SustainableDevelopmentGoal.where("name like :search", search: "%Goal #{sdg[:goal]}:%").first
      if s
        s.name = sdg[:name]
        s.save!
      else
        SustainableDevelopmentGoal.create(name: sdg[:name])
      end
    end
  end
end
