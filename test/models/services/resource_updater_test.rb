require 'test_helper'

class ResourceUpdaterTest < ActiveSupport::TestCase
  context "given submit" do
    setup do
      @params = resource_attributes_with_taggings

      @updater = ResourceUpdater.new(@params)
    end

    should "save the resource" do
      @updater.submit

      assert_equal Resource.count, 1
    end
  end
end
