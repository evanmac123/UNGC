return unless Rails.env.development?

require "factory_girl"

namespace :dev do

  desc "seed the dev environment"
  task prime: [:environment, :"db:seed"] do
    seed_staff_user
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
