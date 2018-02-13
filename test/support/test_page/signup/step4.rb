module TestPage
  module Signup
    class Step4 < TestPage::Base

      def select_engagement_tier(engagement_tier)
        choose(engagement_tier)
      end

      def subscribe_to_action_platform(platform, contact_name)
        platform_selector = "organization_subscriptions_#{platform.id}_selected"
        contact_selector = "organization_subscriptions_#{platform.id}_contact_id"
        check(platform_selector)
        select(contact_name, from: contact_selector)
      end

      def submit
        click_on "Next"
        Step5.new
      end
    end
  end
end
