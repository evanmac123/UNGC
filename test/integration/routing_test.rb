require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  context "Resource routing" do
    should "route to index" do
      assert_routing "/admin/resources", {
        controller: 'admin/resources',
        action: 'index',
      }
    end
  end
end
