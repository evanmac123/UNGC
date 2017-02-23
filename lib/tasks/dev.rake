require "factory_girl"

namespace :dev do
  include FactoryGirl::Syntax::Methods

  desc "seed the dev environment"
  task prime: [:environment, :"db:seed"] do
    create_staff_user
  end

  private

  def create_staff_user
    Contact.find_by(username: "staff") || create(:contact,
      username: "staff",
      password: "Passw0rd",
      organization: Organization.find_by(name: DEFAULTS[:ungc_organization_name])
    )
  end

end
