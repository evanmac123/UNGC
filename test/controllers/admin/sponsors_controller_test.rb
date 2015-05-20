require 'test_helper'

class Admin::SponsorsControllerTest < ActionController::TestCase
  setup do
    @staff_user = create_staff_user

    @params = {
      name: 'Nestle Creating Shared Value',
      website_url: 'http://www.nestle.com/csv',
      logo_url: 'http://www.nestle.com/csv/logo.jpg'
    }
  end

  context "given a staff user" do
    setup do
      sign_in @staff_user
    end

    context 'POST /admin/sponsors' do
      context 'with valid params' do
        setup do
          assert_difference 'Sponsor.count' do
            post :create, sponsor: @params
          end

          @sponsor = Sponsor.last
        end

        should 'set name' do
          assert_equal @params[:name], @sponsor.name
        end

        should 'set website_url' do
          assert_equal @params[:website_url], @sponsor.website_url
        end

        should 'set logo_url' do
          assert_equal @params[:logo_url], @sponsor.logo_url
        end

        should 'redirects to index' do
          assert_redirected_to_index
        end
      end

      context 'with invalid params' do
        # TODO: Determine what params would be invalid.
      end
    end

    context 'GET /admin/sponsors/:id/edit' do
      setup do
        @sponsor = create_sponsor
        get :edit, id: @sponsor.id
      end

      should 'retrieve an sponsor' do
        assert_response :success
      end
    end

    context 'PUT /admin/sponsors/:id' do
      context 'with valid params' do
        setup do
          @sponsor = create_sponsor

          assert_no_difference 'Sponsor.count' do
            put :update, id: @sponsor.id, sponsor: @params
          end

          @sponsor.reload
        end

        should 'set name' do
          assert_equal @params[:name], @sponsor.name
        end

        should 'set website_url' do
          assert_equal @params[:website_url], @sponsor.website_url
        end

        should 'set logo_url' do
          assert_equal @params[:logo_url], @sponsor.logo_url
        end

        should 'redirects to index' do
          assert_redirected_to_index
        end
      end
    end

    context 'DELETE /admin/sponsors/:id' do
      context 'given an sponsor' do
        setup do
          @sponsor = create_sponsor

          assert_difference('Sponsor.count', -1) do
            delete :destroy, id: @sponsor.id
          end
        end

        should 'destroy sponsor' do
          assert_not Sponsor.exists? @sponsor
        end

        should 'redirects to index' do
          assert_redirected_to_index
        end
      end
    end

    context 'GET /admin/sponsors' do
      setup do
        3.times { create_sponsor }

        get :index
      end

      should 'list sponsors' do
        assert_response :success
        assert assigns(:paged_sponsors), 'Instance variable "paged_sponsors" not assigned.'
      end
    end
  end
end
