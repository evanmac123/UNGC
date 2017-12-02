module Crm
  class ActionPlatformSync
    SObjectName = "Action_Platform__c".freeze

    def initialize(crm = Crm::Salesforce.new)
      @crm = crm
    end

    def create(action_platform)
      log("creating", action_platform)
      upsert(action_platform)
    end

    def update(action_platform, fields)
      log("updating", action_platform)
      upsert(action_platform)
    end

    def destroy(action_platform_id)
      @crm.log("destroying Action Platform #{action_platform_id}")
      crm_platform = @crm.find_action_platform(action_platform_id)
      if crm_platform.present?
        @crm.destroy(SObjectName, crm_platform.Id)
      end
    end

    def self.should_sync?(action_platform)
      true
    end

    private

    def upsert(action_platform)
      attrs = {
        "Name" => action_platform.name,
        "UNGC_Action_Platform_ID__c" => action_platform.id.to_s,
        "Description__c" => action_platform.description,
        "Status__c" => action_platform.discontinued ? "discontinued" : nil,
      }.transform_values do |value|
        Crm::Salesforce.coerce(value)
      end

      crm_platform = @crm.find_action_platform(action_platform.id)
      if crm_platform.nil?
        @crm.create(SObjectName, attrs)
      else
        @crm.update(SObjectName, crm_platform.Id, attrs)
        crm_platform.Id
      end
    end

    def log(action, action_platform)
      @crm.log("#{action} Action Platform #{action_platform.name} (#{action_platform.id})")
    end

  end
end
