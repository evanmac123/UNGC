require 'test_helper'

class Redesign::SearchableTest < ActiveSupport::TestCase

  setup do
    Redesign::Searchable.searchable_map = {MockModel => MockSearchable}
    MockModel.reset
  end

  should "index searchables" do
    assert_difference 'Redesign::Searchable.count', 2 do
      Redesign::Searchable.index_all
    end
  end

  should "index new searchables" do
    assert_difference 'Redesign::Searchable.count', 1 do
      Redesign::Searchable.index_new_or_updated
    end
  end

  should "remove old searchables" do
    Redesign::Searchable.index_all
    assert_difference 'Redesign::Searchable.count', -1 do
      Redesign::Searchable.remove(MockModel.first)
    end
  end

  should "update existing searchables" do
    Redesign::Searchable.index_all
    MockModel.first.name = 'updated'

    assert_no_difference 'Redesign::Searchable.count' do
      Redesign::Searchable.index_all # re-index
    end

    assert_equal 'updated', Redesign::Searchable.first.title
  end

  context "the searchable model" do

    setup do
      Redesign::Searchable.index_all
      @searchable = Redesign::Searchable.find_by(title: 'one')
    end

    should "set url" do
      assert_equal "/models/1", @searchable.url
    end

    should "set document_type" do
      assert_equal "Mock", @searchable.document_type
    end

    should "set title" do
      assert_equal "one", @searchable.title
    end

    should "set content" do
      assert_equal "content", @searchable.content
    end

    should "set meta" do
      assert_equal "meta", @searchable.meta
    end

    should "record indexed at time" do
      assert_not_nil @searchable.last_indexed_at
    end

  end

  private

  MockModel = Struct.new(:id, :name) do

    def self.all
      @models ||= reset
    end

    def self.reset
      @models = [new(1, 'one'), new(2, 'two')]
    end

    def self.first
      all.first
    end

  end

  class MockSearchable < Redesign::Searchable::Base

    def self.all
      MockModel.all
    end

    def self.since(_)
      [all.last]
    end

    def url
      "/models/#{model.id}"
    end

    def document_type
      'Mock'
    end

    def title
      model.name
    end

    def content
      'content'
    end

    def meta
      'meta'
    end

  end

end
