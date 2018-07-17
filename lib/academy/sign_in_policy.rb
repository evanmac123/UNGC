# frozen_string_literal: true

module Academy
  class SignInPolicy

    def can_sign_in?(contact)
      case
        when contact.from_ungc?
          true
        when contact.from_network?
          true
        when contact.from_organization?
          contact.organization.participant_level?
        else
          false
      end
    end

  end
end
