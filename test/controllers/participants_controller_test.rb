require 'zlib'
require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase

  setup do
    create_organization_and_user
  end

  should "show by id" do
    get :show, id: @organization.id
    assert_equal assigns(:participant).id, @organization.id
  end

  should "show by slug" do
    get :show, id: @organization.to_param
    assert_equal assigns(:participant).id, @organization.id
  end

  should "show with navigation" do
    get :show, id: @organization, navigation: 'active'
    assert_equal assigns(:participant).id, @organization.id
    assert_match "/participants/active/#{@organization.to_param}", response.body
  end

  should "show the search form" do
    get :search
  end

  context "searching" do

    should "search for keyword" do
      expects_search keyword: 'foo'
      submit_search keyword: 'foo'
    end

    should "filter by country" do
      country_ids = 2.times.map { create_country.id }
      expects_search country_id: country_ids
      submit_search country: country_ids
    end

    context "filter by business type" do

      should "not filter by business type with 'all'" do
        expects_search
        submit_search business_type: 'all'
      end

      context "businesses" do

        should "filter businesses" do
          expects_search business: OrganizationType::BUSINESS
          submit_search business_type: OrganizationType::BUSINESS
        end

        should "filter by cop_state" do
          active_as_crc32_hash = Zlib.crc32('active')
          expects_search business: OrganizationType::BUSINESS, cop_state: active_as_crc32_hash
          submit_search business_type: OrganizationType::BUSINESS, cop_status: 'active'
        end

        should "not filter by cop_state when cop_status is 'all'" do
          expects_search business: OrganizationType::BUSINESS
          submit_search business_type: OrganizationType::BUSINESS, cop_status: 'all'
        end

      end


      context "non-businesses" do

        should "filter non-businesses" do
          expects_search business: OrganizationType::NON_BUSINESS
          submit_search business_type: OrganizationType::NON_BUSINESS
        end

        should "filter by organization_type" do
          expects_search business: OrganizationType::NON_BUSINESS, organization_type_id: 4
          submit_search business_type: OrganizationType::NON_BUSINESS, organization_type_id: "4"
        end

        should "not filter by organization_type when organization_type is blank" do
          expects_search business: OrganizationType::NON_BUSINESS
          submit_search business_type: OrganizationType::NON_BUSINESS, organization_type_id: ""
        end

      end

    end

    should "filter by sector" do
      sector_id = create_sector.id
      expects_search sector_id: sector_id
      submit_search sector_id: sector_id
    end

    context "listing status" do
      should "not filter by Listing Status when 'all'" do
        expects_search
        submit_search listing_status_id: 'all'
      end

      should "filter by Listing Status" do
        status = create_listing_status
        expects_search listing_status_id: status.id
        submit_search listing_status_id: status.id
      end
    end

    context 'fortune 500' do

      should "filter by fortune 500" do
        expects_search is_ft_500: 1
        submit_search is_ft_500: "1"
      end

      should "not filter with an empty value" do
        expects_search
        submit_search is_ft_500: ""
      end

    end

    context "filter by joined_on" do

      setup do
        @after = Time.new(2014, 1, 1)
        @before = Time.new(2014, 12, 31)
        @after_str = @after.strftime('%Y-%m-%d')
        @before_str = @before.strftime('%Y-%m-%d')
      end

      should "filter by joined_on" do
        expects_search joined_on: @after..@before
        submit_search joined_after: @after_str, joined_before: @before_str
      end

      should "not filter with empty joined_after" do
        expects_search
        submit_search joined_after: '', joined_before: @before_str
      end

      should "not filter with empty joined_before" do
        expects_search
        submit_search joined_after: @after_str, joined_before: ''
      end

    end

  end

  private

  def submit_search(params = {})
    defaults = { commit: true }
    post :search, defaults.merge(params)
  end

  def expects_search(args = {})
    keyword = args.delete(:keyword) || ''
    results = MockResults.new([@organization])
    options = {
      per_page: 10,
      page: 1,
      star: true,
      order: 'joined_on DESC'
    }
    options.merge!(with: args) unless args.empty?

    search_service = stub(:search_service)
    search_service.expects(:search).with(keyword, options).returns(results)
    Organization.stubs(participants_only: search_service)
  end

  class MockResults
    include Enumerable

    def initialize(items = [])
      @items = items
    end

    def total_entries
      @items.count
    end

    def each(&block)
      @items.each(&block)
    end

    def total_pages
      1
    end

  end

end
