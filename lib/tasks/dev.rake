namespace :dev do

  desc "seed the dev environment"
  task prime: [:environment, :"db:seed"] do
    if Rails.env.development?
      require "factory_bot"
      seed_staff_user
      action_platforms
    end
  end

  private

  def seed_staff_user
    Contact.find_by(username: "staff") || FactoryBot.create(:contact,
      username: "staff",
      password: "Passw0rd",
      organization: Organization.find_by(name: DEFAULTS[:ungc_organization_name])
    )
  end

  def action_platforms
    Rake::Task["action_platforms:create"]
  end

end
