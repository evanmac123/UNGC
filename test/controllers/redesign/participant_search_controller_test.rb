require 'test_helper'

class Redesign::ParticipantSearchControllerTest < ActionController::TestCase

  # # sets the page
  # # creates a presenter that responds to
  #   blurb
  #   various options
  #   menu
  #   search results

  context "the search form" do

    setup do
      get :index
    end

    should "assign a page" do
      assert_not_nil assigns(:page)
    end

    should "assign a search object" do
      assert_not_nil assigns(:search)
    end

    should "be successful" do
      assert_response :success
    end

  end

  context "searching" do

    setup do
      # stub out the search
      Redesign::ParticipantSearchController::ParticipantSearch::Search
        .any_instance
        .stubs(execute: stub(
          empty?: false,
          any?: true,
          each: []
        ))
    end

    should "assign a page" do
      search
      assert_not_nil assigns(:page)
    end

    should "assign a search object" do
      search
      assert_not_nil assigns(:search)
    end

    should "be successful" do
      search
      assert_response :success
    end

    should "create a search with the params provided" do
      Redesign::ParticipantSearchController::ParticipantSearch::Form
        .expects(:new)
        .with('organization_type' => '123')
        .returns(stub(organization_type: 123))
      search
    end

  end

  private

  def search
    get :search, search: {organization_type: 123}
  end

end
