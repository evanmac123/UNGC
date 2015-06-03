require 'test_helper'

class Redesign::SearchableTest < ActiveSupport::TestCase

  setup do
    @first = create_approved_headline(title: 'one', date: Date.new(2000, 1, 1))
    @second = create_approved_headline(title: 'two', date: Date.new(2008, 11, 4))
  end

  should "index searchables" do
    assert_difference 'Redesign::Searchable.count', 2 do
      Redesign::Searchable.index_all
    end
  end

  should "index new searchables" do
    assert_difference 'Redesign::Searchable.count', 1 do
      cutoff = Date.new(2004, 2, 2)
      Redesign::Searchable.index_new_or_updated(cutoff)
    end
  end

  should "remove old searchables" do
    Redesign::Searchable.index_all
    assert_difference 'Redesign::Searchable.count', -1 do
      Redesign::Searchable.remove(@first)
    end
  end

  should "update existing searchables" do
    Redesign::Searchable.index_all
    @first.update_attribute(:title, 'updated')

    assert_no_difference 'Redesign::Searchable.count' do
      Redesign::Searchable.index_all # re-index
    end

    assert_equal 'updated', @first.title
  end

  context "the searchable model" do

    setup do
      Redesign::Searchable.index_all
      @searchable = Redesign::Searchable.find_by(title: 'one')
    end

    should "set url" do
      assert_match Regexp.new("/news/#{@first.id}-*"), @searchable.url
    end

    should "set document_type" do
      assert_equal "Headline", @searchable.document_type
    end

    should "set title" do
      assert_equal "one", @searchable.title
    end

    should "set content" do
      assert_equal "\ncontent", @searchable.content
    end

    should "set meta" do
      assert_includes @searchable.meta, @first.topics.first.name
    end

    should "record indexed at time" do
      assert_not_nil @searchable.last_indexed_at
    end

  end

  private

  def create_approved_headline(title: nil, date: nil)
    params = {
      title: title,
      created_at: date,
      updated_at: date,
      description: 'content'
    }

    create_headline(params).tap { |h|
      h.approve!
      h.update_attributes(params)
      h.topics.create(valid_topic_attributes)
    }
  end

end
