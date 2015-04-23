require 'test_helper'

class HeadlineUpdaterTest < ActiveSupport::TestCase
  context "given submit" do
    setup do
      @params = headline_attributes_with_taggings

      @updater = HeadlineUpdater.new(@params)
    end

    should "save the headline" do
      @updater.submit

      assert_equal Headline.count, 1
    end

    should "save the taggings" do
      TaggingUpdater.any_instance.expects(:update)

      @updater.submit
    end
  end
end
