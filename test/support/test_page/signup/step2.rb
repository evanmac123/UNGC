module TestPage
  module Signup
    class Step2 < TestPage::Base

      def submit(params = {})
        args = params.reverse_merge(
          FactoryBot.attributes_for(:contact)
        )
        fill_in "Prefix", with: args.fetch(:prefix)
        fill_in "First name", with: args.fetch(:first_name)
        fill_in "Middle name", with: args.fetch(:middle_name)
        fill_in "Last name", with: args.fetch(:last_name)
        fill_in "Job title", with: args.fetch(:title)
        fill_in "Email", with: args.fetch(:email)
        fill_in "Phone", with: args.fetch(:phone)
        fill_in "Postal address", with: args.fetch(:street)
        fill_in "Address cont.", with: args.fetch(:street2)
        fill_in "City", with: args.fetch(:city)
        fill_in "State/Province", with: args.fetch(:state)
        fill_in "ZIP/Code", with: args.fetch(:postal_code)
        select args.fetch(:country), from: "Country"
        fill_in "Username", with: args.fetch(:username)
        fill_in "Password", with: args.fetch(:password)

        click_on "Next"

        Step3.new
      end

    end
  end
end
