module Crm
  class ActionPlatformSubscriptionSync
    SObjectName = "Action_Platform_Subscription__c".freeze

    def initialize(crm = Salesforce.new)
      @crm = crm
      @adapter = Adapter.new(@crm)
      @platform_sync = ActionPlatformSync.new(@crm)
      @contact_sync = ContactSync.new(@crm)
      @organization_sync = OrganizationSync.new(@crm)
    end

    def create(subscription)
      @crm.log("creating ap subscription #{subscription.id}")

      upsert(subscription)
    end

    def update(subscription, fields)
      @crm.log("updating ap subscription #{subscription.id}")

      upsert(subscription)
    end

    def destroy(subscription_id)
      @crm.log("destroying ap subscription #{subscription_id}")

      sub = @crm.find_action_platform_subscription(subscription_id)
      if sub.present?
        @crm.destroy(SObjectName, sub.Id)
      end
    end

    def self.should_sync?(subscription)
      subscription.approved?
    end

    private

    class Adapter < AdapterBase

      def initialize(crm)
        @crm = crm
      end

      def to_crm_params(subscription, organization_id:, platform_id:, contact_id:)
        # TODO: consider caching the mapping between
        # CRM and Database IDs:
        # ungc_id, ungc_type, salesforce_id, salesforce_type

        # TODO: consider asking for new IDS in a single call up-front
        # to cut down on the number of API calls
        # e.g.: get_ids_for_records_since('Account', now - fudge_time)

        {
          "Name" => name(subscription),
          "Created_at__c" => subscription.created_at,
          "Expires_On__c" => subscription.expires_on,
          "Status__c" => text(subscription.status, 255),
          "UNGC_AP_Subscription_ID__c" => subscription.id,
          "Action_Platform__c" => platform_id,
          "Contact_Point__c" => contact_id,
          "Organization__c" => organization_id,
          # We don't sync these:
          # "Withdrawn__c	Checkbox" => "", # Boolean
          # "AP_Subscription_Owner__c" => "", #		Lookup(User)
          # "Invoice_Contribution__c" => "", #		Lookup(Opportunity)
          # "Organization_Owner__c" => "", #		Formula (Text)
        }.transform_values do |value|
          Crm::Salesforce.coerce(value)
        end
      end

      private

      def name(subscription)
        name = "#{subscription.organization.name} - #{subscription.platform.name}"
        text(name, 80)
      end
    end

    def upsert(subscription)
      crm_subscription = @crm.find_action_platform_subscription(subscription.id)

      organization_id = sync_organization(subscription)
      platform_id = sync_platform(subscription)
      contact_id = sync_contact(subscription)

      attrs = @adapter.to_crm_params(subscription,
        organization_id: organization_id,
        platform_id: platform_id,
        contact_id: contact_id,
      )

      if crm_subscription.nil?
        @crm.create(SObjectName, attrs)
      else
        attrs.delete("Organization__c") # we can't update this value once it's been created
        @crm.update(SObjectName, crm_subscription.Id, attrs)
        crm_subscription.Id
      end
    end

    def sync_platform(subscription)
      @platform_sync.create(subscription.platform)
    end

    def sync_contact(subscription)
      @contact_sync.create(subscription.contact)
    end

    def sync_organization(subscription)
      @organization_sync.create(subscription.organization)
    end

  end
end
