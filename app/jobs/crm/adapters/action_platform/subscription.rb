# frozen_string_literal: true

class Crm::Adapters::ActionPlatform::Subscription < Crm::Adapters::Base

  def to_crm_params(transform_action)
    base = Hash['Name', name,
                'Starts_On__c', model.starts_on,
                'Expires_On__c', model.expires_on,
                'Status__c', text(model.state, 255),
    ]
    if transform_action == :create
      base["UNGC_AP_Subscription_ID__c"] = model.id
      base["Created_at__c"] = model.created_at
    end
    base
  end

  private

  def name
    name = "#{model.organization.name} - #{model.platform.name}"
    text(name, 80)
  end

end
