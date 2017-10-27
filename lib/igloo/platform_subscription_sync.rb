module Igloo
  class PlatformSubscriptionSync

    def initialize(api, query: nil)
      @api = api
      @query = query || Igloo::PlatformSubscriptionQuery.new
      @csv_adapter = CsvAdapter.new
      @log = NotificationServiceLogger.new
    end

    def upload_recent(cutoff)
      subscriptions = @query.recent(cutoff)
      converted = subscriptions.map(&method(:convert))
      csv = @csv_adapter.to_csv(converted)
      @api.bulk_upload(csv)
      converted.count
    end

    private

    def convert(subscription)
      contact = subscription.contact
      {
        "firstname" => contact.first_name,
        "lastname" => contact.last_name,
        "email" => contact.email,
        "customIdentifier" => contact.id,
        "sector" => contact.organization.sector.name,
        "country" => contact.country.name,
        "company" => contact.organization.name,
        "occupation" => contact.job_title,
        "groupsToAdd" => add(subscription),
        "groupsToRemove" => remove(subscription),
      }
    end

    def add(subscription)
      if subscription.active?
        space_name(subscription.platform.name)
      end
    end

    def remove(subscription)
      if subscription.inactive?
        space_name(subscription.platform.name)
      end
    end

    # Members are added to Igloo spaces by appending "~Space Members"
    # To the name of the group. This `space_name` translates the ActionPlatform name
    # in the database to match the Spaces in Igloo
    def space_name(platform_name)
      igloo_name = if SPACE_NAMES.key?(platform_name)
                     SPACE_NAMES.fetch(platform_name)
                   else
                     # we don't have a known igloo group name, flag it
                     # and assume it's the same as the platform name
                     @log.error "No Igloo space name registered for #{platform_name}"
                     platform_name
                   end
      "#{igloo_name}~Space Members"
    end

    SPACE_NAMES = {
      "The Blueprint for SDG Leadership" => "Blueprint for SDG Leadership",
      "Reporting on the SDGs" => "Reporting on the SDGs",
      "Breakthrough Innovation" => "Breakthrough Innovation for the SDGs",
      "Financial Innovation for the SDGs" => "Financial Innovation for the SDGs",
      "Pathways to Low-Carbon & Resilient Development" => "Pathways to Low-Carbon &amp; Resilient Development",
      "Health is Everyone's Business" => "Health is Everyone&#39;s Business",
      "Business for Inclusion" => "Business for Inclusion &amp; Gender Equality",
      "Business Action for Humanitarian Needs" => "Business for Humanitarian Action and Peace",
      "Decent Work in Global Supply Chains" => "Decent Work in Global Supply Chains",
      "Water Stewardship for the SDGs" => "Water Stewardship for the SDGs",
    }.freeze

  end
end
