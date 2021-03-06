require 'test_helper'

class LibraryControllerTest < ActionController::TestCase

  setup do
    Resource.stubs(search: stub(
      total_entries: 0,
      total_pages: 0,
      each: stub(),
      any?: true,
      empty?: false
    ))
  end

  context "index" do

    setup do
      @container = create(:container, layout: :library, path: '/library', slug: '/library')

      @public_resources = [{resource_id: create(:resource).id}]
      @public_payload = create(:payload,
        container_id: @container.id,
        data: {featured: @public_resources})

      @draft_resources = [{resource_id: create(:resource).id}]
      @draft_payload = create(:payload,
        container_id: @container.id,
        data: {featured: @draft_resources})

      @container.public_payload = @public_payload
      @container.draft_payload = @draft_payload
      @container.save!
    end

    should "create a blank form" do
      get :index
      assert_not_nil assigns(:search)
    end

    should "have featured content" do
      get :index
      page = assigns(:page)
      assert_equal @public_resources.map {|r| r[:resource_id] }, page.featured.map(&:id)
    end

    should "show draft content to staff when asked" do
      create_staff_user
      sign_in @staff_user
      get :index, draft: true

      page = assigns(:page)
      assert_equal @draft_resources.map {|r| r[:resource_id] }, page.featured.map(&:id)
    end

    should "respond to page[:title]" do
      get :index
      page = assigns(:page)
      assert_nil page[:title]
    end

  end

  context "search" do

    setup do
      @language = Language.english

      # Leaf nodes
      @issue = Issue.children.find_by(name: 'Indigenous Peoples')
      @topic = Topic.children.find_by(name: 'UN-Business Partnerships')
      @sector = Sector.children.find_by(name: 'Oil & Gas Producers')

      @search_params = {
        "issues" => [@issue.id],
        "topics" => [@topic.id],
        "languages" => [@language.id],
        "sectors" => [@sector.id],
        "content_type" => '0',
        "sort_field" => 'title_acs'
      }.deep_stringify_keys
    end

    context "form" do

      setup do
        get :search, {
          page: 3,
          search: @search_params
        }
        @search = assigns(:search)
      end

      should "filter issues" do
        assert_filters_for @search.active_filters, @issue
      end

      should "filter topics" do
        assert_filters_for @search.active_filters, @topic
      end

      should "filter languages" do
        assert_filters_for @search.active_filters, @language
      end

      should "filter sectors" do
        assert_filters_for @search.active_filters, @sector
      end

    end

    context "results" do

      setup do
        get :search, {
          page: 3,
          search: @search_params
        }
        @search = assigns(:search)
      end

      should "have results" do
        assert_not_nil assigns(:results)
      end

    end

  end

  private

  def assert_filters_for(filters, model)
    filters.each do |filter|
      if filter.id == model.id
        return true
      end
    end
    fail "#{filters} does not contain a filter for #{model.class} with id: #{model.id}"
  end

end
