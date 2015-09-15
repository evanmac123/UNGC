require 'test_helper'

class CoeMailerTest < ActionMailer::TestCase

  [
    :confirmation_blueprint,
    :confirmation_learner,
    :confirmation_double_learner,
    :confirmation_triple_learner_for_one_year,
    :confirmation_active,
    :confirmation_advanced,
    :confirmation_non_business,
    :communication_due_in_90_days,
    :communication_due_in_30_days,
    :communication_due_today,
    :communication_due_yesterday,
    :delisting_in_9_months,
    :delisting_in_90_days,
    :delisting_in_30_days,
    :delisting_in_7_days,
    :delisting_today,
  ].each do |method|

    should "respond to #{method}" do
      assert CoeMailer.respond_to?(method), "CoeMailer needs to implement #{method}"
    end

  end

  end
