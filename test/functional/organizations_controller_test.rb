require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  context "given a json request to index" do
    setup do
      @climate    = create_initiative(:id => 2, :name => 'Caring for Climate')
      @other_init = create_initiative(:id => 4, :name => 'Human Rights')
    end
    should "return an empty array if none exist" do
      get :index, {}, :format => :json
      
      assert_response :success
      response = JSON.parse(@response.body)
      assert_equal [], response['organizations']
    end

    context "without parameters" do
      setup do
        create_organization_and_user('approved')
        @climate.signings.create :signatory => @organization
      end

      should "properly represent response headers" do
        get :index, {}, :format => :json
        assert_response :success

        assert_equal Organization.per_page.to_s, @response.headers['Per-Page']
        assert_equal '1', @response.headers['Current-Page']
        assert_equal '1', @response.headers['Total-Entries']
      end

      should "return climate initiatives" do
        get :index, {}, :format => :json

        assert_response :success
        response = JSON.parse(@response.body)
        assert_equal 1, response['organizations'].count
      end

      should "return default attributes" do
        default_attributes = ['id', 'name','sector_name', 'country_name', 'participant']
        get :index, {}, :format => :json

        assert_response :success
        response = JSON.parse(@response.body)
        assert_equal default_attributes.sort, response['organizations'].first.keys.sort
      end
    end

    context "with parameters" do
      setup do
        create_organization_and_user('approved')
        @climate.signings.create :signatory => @organization
        @org2 = create_organization
        @other_init.signings.create :signatory => @org2
        @page = '2'
        @per_page = '1'
      end

      context "with an initiative parameter" do
        setup do
          create_organization_and_user('approved')
        end

        should "return related initiatives" do
          get :index, {:initiative => 'human_rights'}, :format => :json

          assert_response :success
          response = JSON.parse(@response.body)
          assert_equal 1, response['organizations'].count
        end
      end

      context "with a page and per_page parameter" do
        should "return expected results" do
          get :index, {:page => @page, :per_page => @per_page}, :format => :json
          assert_response :success

          assert_equal [], JSON.parse(@response.body)['organizations']
        end

        should "properly represent response headers" do
          get :index, {:page => @page, :per_page => @per_page}, :format => :json
          assert_response :success

          assert_equal @per_page, @response.headers['Per-Page']
          assert_equal @page, @response.headers['Current-Page']
          assert_equal '1', @response.headers['Total-Entries']
        end
      end

      context "with an extras parameter" do
        setup do
          @default_attributes = ['id', 'name','sector_name', 'country_name', 'participant']
        end

        should "return expected attributes" do
          expected_attributes = @default_attributes.push("stock_symbol")
          get :index, {:extras => "stock_symbol"}, :format => :json
          assert_response :success

          response = JSON.parse(@response.body)
          assert_equal expected_attributes.sort, response['organizations'].first.keys.sort
        end
      end

      context "with methods parameters" do
        setup do
          @default_attributes = ['id', 'name','sector_name', 'country_name', 'participant']
        end

        should "return expected attributes" do
          expected_attributes = @default_attributes.push("local_network_name", "local_network_country_code")
          get :index, {:methods => 'local_network_name,local_network_country_code'}, :format => :json
          assert_response :success

          response = JSON.parse(@response.body)
          assert_equal expected_attributes.sort, response['organizations'].first.keys.sort
        end
      end
    end

  end

end
