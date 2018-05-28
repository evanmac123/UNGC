module TestPage
  module Signup
    class Step6 < TestPage::Base
      def submit(commitment_letter:, registry_url:, accepts_eula:)
        attach_file "organization_commitment_letter", commitment_letter
        fill_in "organization[government_registry_url]", with: registry_url
        check("organization_accepts_eula") if accepts_eula

        click_on "Submit"
      end
    end
  end
end
