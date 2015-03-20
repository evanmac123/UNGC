require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase
  context "visiting a single resource" do
    setup do
      @resource = create_resource(year: Date.today)
      @resource.approve!
    end

    should "increment views count" do
      assert_equal @resource.views, 0
      get :show, :id => @resource.id
      assert_response :success
      @resource.reload
      assert_equal @resource.views, 1
    end
  end

  context "clicking a resource link" do
    setup do
      @resource = create_resource(year: Date.today)
      @resource.approve!
      @resource_link = create_resource_link(resource: @resource)
    end

    should "increment views count" do
      assert_equal @resource_link.views, 0
      post :link_views, :resource_link_id => @resource_link.id, format: :js
      assert_response :success
      @resource_link.reload
      assert_equal @resource_link.views, 1
    end
  end

  test "#index" do
    resource = create_resource
    ResourceFeatured.any_instance.stubs(find_resources: [resource])
    get :index
  end

  test "#index with search terms" do
    search = mock('search')
    ResourceSearch.stubs(new: search)

    search.expects(:page=, 5)
    search.expects(:per_page=, 6)
    search.expects(:order=, 'foo')
    search.expects(:get_search_results).returns(stub(total_count: 1, total_pages: 1, each: stub(:[])))
    search.expects(:results_description).returns('description')

    get :index, commit: 'Search',
      page: 5,
      per_page: 6,
      order: 'foo',
      resource_search: {
        keyword: 'lasers',
        language: [1],
        author: [2],
        topic: {
          principle_ids: [3,4]
        }
      }
  end

end
