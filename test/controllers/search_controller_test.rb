require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  context "generated" do

    should "show search form" do
      get :index
      assert_response :success
    end

    should "submit a search" do
      options = {page: nil, per_page: 25, star: true}

      results = ThinkingSphinx::Search.new([])
      Searchable.expects(:search).with('human rights', options).returns(results)

      get :index, keyword: 'human rights'
      assert_response :success
    end

    should "submit a document type search" do
      options = {page: nil, per_page: 25, star: true}

      results = ThinkingSphinx::Search.new([])
      Searchable.expects(:faceted_search).with('pdf', 'human rights', options).returns(results)

      get :index, keyword: 'human rights', document_type: 'pdf'
      assert_response :success
    end

  end
end
