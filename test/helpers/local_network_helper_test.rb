require 'test_helper'

class LocalNetworkHelperTest < ActionView::TestCase

  # the most basic of tests to at least run the code

  should "exercise cop_due_in_days(days)" do
    cop_due_in_days(10)
  end

  should "exercise delisted_in_days(days)" do
    delisted_in_days(10)
  end

  should "exercise participants_became_noncommunicating(days)" do
    participants_became_noncommunicating(10)
  end

  should "exercise participants_became_delisted(days)" do
    participants_became_delisted(10)
  end

  should "exercise approved_logo_requests(days)" do
    approved_logo_requests(10)
  end

end
