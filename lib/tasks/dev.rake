namespace :dev do

  desc "seed the dev environment"
  task prime: [:environment, :"db:seed"] do
    if Rails.env.development?
      require "factory_girl"
      seed_staff_user
    end
  end

  private

  def seed_staff_user
    Contact.find_by(username: "staff") || FactoryGirl.create(:contact,
      username: "staff",
      password: "Passw0rd",
      organization: Organization.find_by(name: DEFAULTS[:ungc_organization_name])
    )
  end

end
