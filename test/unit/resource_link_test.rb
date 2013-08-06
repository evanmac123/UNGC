require 'test_helper'

class ResourceLinkTest < ActiveSupport::TestCase
  should belong_to :resource
  should belong_to :language

  context "resource link creation" do

    should "create a valid resource link" do
      resource_link = ResourceLink.new title: "resource title 1", link_type: "pdf"
      assert resource_link.valid?
    end

    should "not create an invalid resource link" do
      resource_link = ResourceLink.new title: "resource title 1", link_type: ResourceLink::TYPES[:pdf]
      assert !resource_link.valid?
    end

  end
end
