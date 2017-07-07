module Igloo
  class SignInPolicy

    def initialize(queries: nil)
      @queries = queries || [
        StaffQuery.new,
        LocalNetworkQuery.new,
        PlatformSubscriptionQuery.new,
      ]
    end

    def can_sign_in?(contact)
      @queries.any? do |query|
        query.include?(contact)
      end
    end

  end
end
