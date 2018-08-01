# frozen_string_literal: true

module Academy
  class SignInPolicy

    def can_sign_in?(contact)
      case
        when contact.from_ungc?
          can_sign_in_as_staff?(contact)
        when contact.from_network?
          can_sign_in_from_local_network?(contact)
        when contact.from_organization?
          can_sign_in_from_organization?(contact.organization)
        else
          false
      end
    end

    private

    def can_sign_in_as_staff?(contact)
      contact.is?(Role.academy_manager)
    end

    def can_sign_in_from_organization?(organization)
      organization.active &&
        organization.active? &&
        organization.participant? &&
        organization.participant_level?
    end

    def can_sign_in_from_local_network?(contact)
      contact.is?(Role.academy_local_network_representative)
    end

  end
end
