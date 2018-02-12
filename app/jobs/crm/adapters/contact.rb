# frozen_string_literal: true

module Crm
  module Adapters
    class Contact < Crm::Adapters::Base

      def to_crm_params(transform_action)
        base = {
            'UNGC_Contact_ID__c' => number(model.id),
            'Salutation' => picklist(model.prefix),
            'FirstName' => text(model.first_name, 40),
            'LastName' => text(model.last_name, 80),
            'Title' => text(model.job_title, 128),
            'OwnerId' => find_owner,
            'Email' => email(model.email),
            'Phone' => phone(model.phone),
            'MobilePhone' => phone(model.mobile),
            'Fax' => fax(model.fax),
            'Role__c' => picklist(model.roles.pluck(:name)),
            'MailingStreet' => text(model.full_address),
            'MailingCity' => text(model.city, 40),
            'MailingState' => text(model.state),
            'MailingPostalCode' => postal_code(model.postal_code),
            'MailingCountry' => text(model.country.name),
        }

        base['npe01__PreferredPhone__c'] = 'Work' if transform_action == :create

        base
      end

      private

      def find_owner
        if model.organization
          owner_id = model.organization&.participant_manager&.crm_owner&.crm_id
          owner_id || Crm::Owner::SALESFORCE_OWNER_ID
        elsif model.local_network
          Crm::Owner::SALESFORCE_OWNER_ID
        end
      end

    end
  end
end
