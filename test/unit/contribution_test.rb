require 'test_helper'

class ContributionTest < ActiveSupport::TestCase
  should validate_presence_of :contribution_id
  should validate_presence_of :date
  should validate_presence_of :stage
  should validate_presence_of :organization_id

  should "use recognition_amount when it's present" do
    contribution = Contribution.new(recognition_amount: 123, raw_amount: 456)
    assert_equal 123, contribution.amount
  end

  should "use raw_amount when recognition_amount is not present" do
    contribution = Contribution.new(recognition_amount: nil, raw_amount: 456)
    assert_equal 456, contribution.amount
  end

end
