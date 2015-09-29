require 'test_helper'

class CoeMailerTest < ActionMailer::TestCase

  [
    :communication_on_engagement_90_days,
    :communication_on_engagement_30_days,
    :communication_on_engagement_1_week_before_nc,
    :communication_on_engagement_due_today,
    :communication_on_engagement_nc_day_notification,
    :communication_on_engagement_1_month_after_nc,
    :communication_on_engagement_9_months_before_expulsion,
    :communication_on_engagement_3_months_before_expulsion,
    :communication_on_engagement_1_month_before_expulsion,
    :communication_on_engagement_2_weeks_before_expulsion,
    :communication_on_engagement_1_week_before_expulsion,
    :delisting_today,
  ].each do |method|
    should "respond to #{method}" do
      assert CoeMailer.respond_to?(method), "CoeMailer needs to implement #{method}"
    end
  end

end
