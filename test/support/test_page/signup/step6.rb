module TestPage
  module Signup
    class Step6 < TestPage::Base
      def submit(args)
        attach_file "organization_commitment_letter", args.fetch(:commitment_letter)
        fill_in "organization[government_registry_url]", with: args.fetch(:registry_url)
        click_on "Submit"
      end
    end
  end
end
