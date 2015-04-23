require 'test_helper'

class HeadlineUpdaterTest < ActiveSupport::TestCase
  context "given submit" do
    setup do
      @issues = create_issue_hierarchy
      @topics = create_topic_hierarchy
      @sectors = create_sector_hierarchy

      @issue = @issues.last.issues.last
      @topic = @topics.last.children.last
      @sector = @sectors.last.children.last

      @params = {
        title: "UN Global Compact Launches Local Network in Canada",
        published_on: "2015-04-23",
        location: "Toronto, Ontario",
        country_id: 30,
        description: "Global Compact Network Canada was launched in Toronto...",
        headline_type: "press_release",
        issues: [@issue.id],
        topics: [@topic.id],
        sectors: [@sector.id]
      }
      @updater = HeadlineUpdater.new(@params)
      @updater.submit
    end

    should "save the headline" do
      assert_equal Headline.count, 1
    end

    should "save the taggings" do
      assert_not_empty @updater.headline.taggings.where(issue_id: @issue.id)
      assert_not_empty @updater.headline.taggings.where(topic_id: @topic.id)
      assert_not_empty @updater.headline.taggings.where(sector_id: @sector.id)
    end
  end
end
