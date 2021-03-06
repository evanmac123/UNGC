module SearchableTagTests
  extend ActiveSupport::Concern

  included do

    should "index by topics" do
      topic = create(:topic)
      subject.topics << topic

      Searchable.index_all
      searchable = Searchable.last

      assert_match(/#{topic.name}/, searchable.meta)
    end

    should "index by issues" do
      issue = create(:issue)
      subject.issues << issue

      Searchable.index_all
      searchable = Searchable.last

      assert_match(/#{issue.name}/, searchable.meta)
    end

    should "index by sectors" do
      sector = create(:sector)
      subject.sectors << sector

      Searchable.index_all
      searchable = Searchable.last

      assert_match(/#{sector.name}/, searchable.meta)
    end

  end

end
