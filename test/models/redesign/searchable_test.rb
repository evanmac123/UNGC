require 'test_helper'

class Redesign::SearchableTest < ActiveSupport::TestCase

  MockModel = Struct.new(:id, :name)

  class MockSearchable < Redesign::Searchable::Base

    def self.all
      [
        MockModel.new(1, 'one'),
        MockModel.new(2, 'two')
      ]
    end

    def self.since(cutoff)
      [
        MockModel.new(2, 'two')
      ]
    end

    def url
      model.id
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

  should "index searchables" do
    Redesign::Searchable.searchable_map = {MockModel => MockSearchable}

    assert_difference 'Redesign::Searchable.count', 2 do
      Redesign::Searchable.index_all
    end
  end

  should "index new searchables" do
    Redesign::Searchable.searchable_map = {MockModel => MockSearchable}

    assert_difference 'Redesign::Searchable.count', 1 do
      Redesign::Searchable.index_since(:some_date)
    end
  end

  should "remove old searchables" do
    Redesign::Searchable.searchable_map = {MockModel => MockSearchable}
    Redesign::Searchable.index_all

    assert_difference 'Redesign::Searchable.count', -1 do
      Redesign::Searchable.remove(MockModel.new(1, 'one'))
    end
  end

  should "update existing searchables" do
    Redesign::Searchable.searchable_map = {MockModel => MockSearchable}
    Redesign::Searchable.index_all

    Redesign::Searchable.searchable_map = {MockModel => MockSearchable}
    Redesign::Searchable.index_all
  end

  context "the searchable model" do

    setup do
      Redesign::Searchable.searchable_map = {MockModel => MockSearchable}
      Redesign::Searchable.index_all
      @searchable = Redesign::Searchable.find_by(title: 'one')
    end

    should "set url" do
      assert_equal "wrong", @searchable.url
    end

    should "set document_type" do
      assert_equal "wrong", @searchable.document_type
    end

    should "set title" do
      assert_equal "wrong", @searchable.title
    end

    should "set content" do
      assert_equal "wrong", @searchable.content
    end

    should "set meta" do
      assert_equal "wrong", @searchable.meta
    end

  end

end
