# frozen_string_literal: true

class Crm::Adapters::ActionPlatform::Platform < Crm::Adapters::Base

  def to_crm_params(transform_action)
    base = Hash['Name', model.name, 'Description__c', model.description]
    base["Status__c"] = 'discontinued' if model.discontinued?
    base["UNGC_Action_Platform_ID__c"] = model.id.to_s if transform_action == :create
    base
  end
end
