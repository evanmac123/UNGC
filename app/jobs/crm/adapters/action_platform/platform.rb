# frozen_string_literal: true

class Crm::Adapters::ActionPlatform::Platform < Crm::Adapters::Base

  def build_crm_payload
    column('Name', :name)
    column('Description__c', :description)
    column('Status__c', :discontinued) { |platform| platform.discontinued? ? 'discontinued' : nil }
    column('UNGC_Action_Platform_ID__c', :id) { |platform| platform.id.to_s }
  end
end
