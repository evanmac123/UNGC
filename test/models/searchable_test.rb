require 'test_helper'

class SearchableTest < ActiveSupport::TestCase

  setup do
    @first = create_approved_headline(title: 'one', date: Date.new(2000, 1, 1))
    @second = create_approved_headline(title: 'two', date: Date.new(2008, 11, 4))
  end

  should "index searchables" do
    assert_difference 'Searchable.count', 2 do
      Searchable.index_all
    end
  end

  should "index new searchables" do
    assert_difference 'Searchable.count', 1 do
      cutoff = Date.new(2004, 2, 2)
      Searchable.index_new_or_updated(cutoff)
    end
  end

  should "remove old searchables" do
    Searchable.index_all
    assert_difference 'Searchable.count', -1 do
      Searchable.remove(@first)
    end
  end

  should "update existing searchables" do
    Searchable.index_all
    @first.update_attribute(:title, 'updated')

    assert_no_difference 'Searchable.count' do
      Searchable.index_all # re-index
    end

    assert_equal 'updated', @first.title
  end

  context "the searchable model" do

    setup do
      Searchable.index_all
      @searchable = Searchable.find_by(title: 'one')
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
