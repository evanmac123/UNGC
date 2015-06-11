module SearchableTagTests
  extend ActiveSupport::Concern

  included do

    should "index by topics" do
      topic = create_topic
      subject.topics << topic

      Redesign::Searchable.index_all
      searchable = Redesign::Searchable.last

      assert_match(/#{topic.name}/, searchable.meta)
    end

    should "index by issues" do
      issue = create_issue
      subject.issues << issue

      Redesign::Searchable.index_all
      searchable = Redesign::Searchable.last

      assert_match(/#{issue.name}/, searchable.meta)
    end

    should "index by sectors" do
      sector = create_sector
      subject.sectors << sector

      Redesign::Searchable.index_all
      searchable = Redesign::Searchable.last

      assert_match(/#{sector.name}/, searchable.meta)
    end

  end

end
