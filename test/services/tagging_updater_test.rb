require 'test_helper'

class TaggingUpdaterTest < ActiveSupport::TestCase
  context "given submit" do
    setup do
      @params = headline_attributes_with_taggings
      headline = create_headline

      taggings = @params.slice(:issues,:topics,:sectors)

      @updater = TaggingUpdater.new(taggings, headline)
      @updater.submit

      @headline = @updater.object
    end

    should "save the taggings" do
      assert_equal @headline.issues.count, 1
      assert_equal @headline.topics.count, 1
      assert_equal @headline.sectors.count, 1
    end
  end
end
