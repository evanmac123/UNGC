require 'test_helper'

class Redesign::LibraryControllerTest < ActionController::TestCase

  setup do
    Resource.stubs(search: stub(
      total_entries: 0,
      total_pages: 0,
      each: stub(),
      any?: true
    ))
  end

  context "index" do

    setup do
      @container = create_container layout: :landing, slug: '/redesign/our-library'

      @public_resources = [create_resource.id]
      @public_payload = create_payload(
        container_id: @container.id,
        json_data: {featured: @public_resources}.to_json)

      @draft_resources = [create_resource.id]
      @draft_payload = create_payload(
        container_id: @container.id,
        json_data: {featured: @draft_resources}.to_json)

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
      assert_equal @public_resources, page.featured.map(&:id)
    end

    should "show draft content to staff when asked" do
      sign_in create_staff_user
      get :index, draft: true

      page = assigns(:page)
      assert_equal @draft_resources, page.featured.map(&:id)
    end

    should "respond to page[:title]" do
      get :index
      page = assigns(:page)
      assert_nil page[:title]
    end

  end

  context "search" do

    setup do
      @issues = create_issue_hierarchy
      @topics = create_topic_hierarchy
      @sectors = create_sector_hierarchy

      @language = create_language
      @issue = @issues.last.issues.last
      @topic = @topics.last.children.last
      @sector = @sectors.last.children.last

      @search_params = {
        "issues" => {@issue.id => '1'},
        "topics" => {@topic.id => '1'},
        "languages" => {@language.id => '1'},
        "sectors" => {@sector.id => '1'},
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
