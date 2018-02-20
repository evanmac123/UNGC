# frozen_string_literal: true

module Crm
  module Adapters
    class Contact < Crm::Adapters::Base

      def build_crm_payload
        column('UNGC_Contact_ID__c', :id)
        column('npe01__PreferredPhone__c', :id) { 'Work' }
        column('Salutation', :prefix)
        column('FirstName', :first_name) { |contact| text(contact.first_name, 40) }
        column('LastName', :last_name) { |contact| text(contact.last_name, 80) }
        column('Title', :job_title) { |contact| text(contact.job_title, 128) }
        owner_has_changed = changed?(:organization_id) || changed?(:local_network_id)
        column('OwnerId', nil, owner_has_changed) do |contact|
          if contact.organization
            owner_id = contact.organization&.participant_manager&.crm_owner&.crm_id
            owner_id || Crm::Owner::SALESFORCE_OWNER_ID
          elsif contact.local_network
            Crm::Owner::SALESFORCE_OWNER_ID
          end
        end
        column('Email', :email)
        column('Phone', :phone) { |contact| text(contact.phone, 40) }
        column('MobilePhone', :mobile) { |contact| text(contact.mobile, 40) }
        column('Fax', :fax) { |contact| text(contact.fax, 40) }
        roles_changed = relation_changed?(:roles)
        column('Role__c', :roles, roles_changed) { |contact| picklist(contact.roles.pluck(:name)) }
        street_has_changed = changed?(:address) || changed?(:address_more)
        column('MailingStreet', nil, street_has_changed) { |contact| contact.full_address }
        column('MailingCity', :city) { |contact| text(contact.city, 40) }
        column('MailingState', :state)
        column('MailingPostalCode', :postal_code) { |contact| text(contact.postal_code, 20) }
        column('MailingCountry', :country_id) { |contact| contact.country.name }
      end
    end
  end
end
