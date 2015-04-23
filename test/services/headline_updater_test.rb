require 'test_helper'

class HeadlineUpdaterTest < ActiveSupport::TestCase
  context "given submit" do
    setup do
      @params = headline_attributes_with_taggings

      @updater = HeadlineUpdater.new(@params)
      @updater.submit
    end

    should "save the headline" do
      assert_equal Headline.count, 1
    end

    should "save the taggings" do
      assert_equal @updater.headline.issues.count, 1
      assert_equal @updater.headline.topics.count, 1
      assert_equal @updater.headline.sectors.count, 1
    end

  end
end
