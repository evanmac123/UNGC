module TestPage
  module Signup
    class Step5 < TestPage::Base
      def fill_in_contact(args)
        select "Mrs.", from: "contact_prefix"
        fill_in "First name", with: args.fetch(:first_name)
        fill_in "Last name", with: args.fetch(:last_name)
        fill_in "Job title", with: args.fetch(:title)
        fill_in "Email", with: args.fetch(:email)
        fill_in "Phone", with: args.fetch(:phone)
      end

      def check_same_as_primary_contact
        check "The primary contact is also the financial contact"
      end

      def submit
        click_on "Next"
        Step6.new
      end
    end
  end
end
