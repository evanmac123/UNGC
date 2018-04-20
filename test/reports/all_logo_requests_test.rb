require "test_helper"

class AllLogoRequestsTest < ActiveSupport::TestCase

  should "at least run the report" do
    travel_to Date.parse("2018-1-2") do
      create(:logo_request)
      report = AllLogoRequests.new
      results = report.to_h
      assert_equal "2018-01-02", results.dig(0, "Date Received")
    end
  end
end
