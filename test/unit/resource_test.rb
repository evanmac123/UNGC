require 'test_helper'

class ResourceTest < ActiveSupport::TestCase
  should have_and_belong_to_many :principles
  should have_and_belong_to_many :authors
  should have_many :resource_links
  should validate_presence_of :title
  should validate_presence_of :description

  context "resource creation" do
    setup do
      @resource = Resource.create title: "resource title 1", description: "present", image_url: "http://www.google.it", year: "2001"
    end

    should "create a resource and set it to the pending state" do
      assert_equal ContentApproval::STATES[:pending], @resource.approval
    end

    should "be approvable" do
      @resource.approve!
      assert_equal ContentApproval::STATES[:approved], @resource.approval
    end

  end

end
