# frozen_string_literal: true

module Crm
  class ActionPlatformSync
    attr_reader :model, :changes

    SObjectName = "Action_Platform__c"

    def initialize(model, changes, crm = Crm::Salesforce.new)
      @model = model
      @changes = changes
      @crm = crm
    end

    def create
      log("creating")
      upsert
    end

    def update
      log("updating")
      upsert
    end

    def destroy(action_platform_id)
      @crm.log("destroying Action Platform #{action_platform_id}")
      crm_platform = @crm.find_action_platform(action_platform_id)
      @crm.destroy(SObjectName, crm_platform&.Id)
    end

    private

    def upsert
      attrs = {
        "Name" => model.name,
        "UNGC_Action_Platform_ID__c" => model.id.to_s,
        "Description__c" => model.description,
        "Status__c" => model.discontinued ? "discontinued" : nil,
      }.transform_values do |value|
        Crm::Salesforce.coerce(value)
      end

      crm_platform = @crm.find_action_platform(model.id)
      if crm_platform.nil?
        @crm.create(SObjectName, attrs)
      else
        @crm.update(SObjectName, crm_platform.Id, attrs)
        crm_platform.Id
      end
    end

    def log(action)
      @crm.log("#{action} Action Platform #{model.name} (#{model.id})")
    end

  end
end
