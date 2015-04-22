require 'test_helper'

class Admin::NewsControllerTest < ActionController::TestCase
  context "given a staff user" do
    setup do
      @staff_user = create_staff_user
      sign_in @staff_user

      @headline = create_headline
      @update = {
        title: "UN Global Compact Launches Local Network in Canada",
        location: "Toronto, Ontario",
        country: 30,
        body: "Global Compact Network Canada was launched in Toronto...",
        headline_type: "press_releases"
      }
    end

    should "get index" do
      get :index
      assert_response :success

      assert_select 'table.dashboard_table tr', 2
    end

    should "get new" do
      get :new
      assert_response :success
      assert_select 'select#headline_headline_type', 1
    end

    context "given create headline" do
      setup do
        assert_difference 'Headline.count', 1 do
          post :create, headline: @update
        end

        @headline = Headline.find_by_title(@update[:title])
      end

      should "redirect to index" do
        assert_redirected_to_index
      end

      should "set state to pending approval" do
        assert @headline.pending?
      end

      should "set headline type" do
        assert_equal @update[:headline_type], @headline.headline_type
      end

      context "given approval" do
        setup do
          assert_no_difference 'Headline.count' do
            post :approve, id: @headline.id
          end

          @headline.reload
        end

        should "approve the headline" do
          assert @headline.approved?
          assert_contains Headline.approved, @headline
          assert_redirected_to_index
        end

        should "be updated_by the staff member" do
          assert_equal @staff_user.id, @headline.updated_by_id
        end

        context "given revocation" do
          setup do
            # clear updated_by_id so we're sure it gets set.
            @headline.update_attribute :updated_by_id, nil

            assert_no_difference 'Headline.count' do
              post :revoke, {:id => @headline.id}
            end

            @headline.reload
          end

          should "revoke approval of the headline" do
            assert @headline.revoked?
            assert_does_not_contain Headline.approved, @headline
            assert_redirected_to_index
          end

          should "be updated_by the staff member" do
            assert_equal @staff_user.id, @headline.updated_by_id
          end
        end
      end
    end

    should "get edit" do
      get :edit, id: @headline.to_param
      assert_response :success
      assert_select 'select#headline_headline_type', 1
    end

    should "update headline" do
      assert_no_difference 'Headline.count' do
        post :update, id: @headline, headline: @update
      end

      assert_equal @update[:title], Headline.find(@headline.id).title
      assert_redirected_to_index
    end

    should "destroy headline" do
      assert_difference('Headline.count', -1) do
        delete :destroy, id: @headline.to_param
      end

      assert_redirected_to admin_headlines_path
    end
  end
end
