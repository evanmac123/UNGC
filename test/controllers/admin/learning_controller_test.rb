require 'test_helper'


class Admin::LearningControllerTest < ActionController::TestCase

  context "generated" do

    setup do
      Principle.create! name: "Global Compact"
      Principle.create! name: "Human Rights"
      Principle.create! name: "Labour"
      Principle.create! name: "Environment"
      Principle.create! name: "Anti-Corruption"
      Principle.create! name: 'Business and Peace'
      Principle.create! name: "Financial Markets"
      Principle.create! name: "Business for Development"
      Principle.create! name: "UN / Business Partnerships"
      Principle.create! name: "Supply Chain Sustainability"
      create_staff_user
      sign_in @staff_user
    end

    should "#index" do
      get :index
      assert_response :success
    end

    should "#search" do
      search = mock('search')
      search.stubs(:page=)
      search.stubs(:per_page=)
      entries = []
      search.stubs(:results).returns(stub(
        total_entries: entries,
        each: entries.each,
        total_pages: 0
      ))

      LocalNetworkEventSearch.stubs(:new).returns(search)

      get :search, local_network_event_search: {term: 'query'}
      assert_response :success
    end

  end
end
