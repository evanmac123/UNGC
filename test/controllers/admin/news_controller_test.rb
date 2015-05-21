require 'test_helper'

class Admin::NewsControllerTest < ActionController::TestCase
  context "given a staff user" do
    setup do
      @staff_user = create_staff_user
      sign_in @staff_user

      @headline = create_headline
      @update = headline_attributes_with_taggings
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

      should "set title" do
        assert_equal @update[:title], @headline.title
      end

      should "set published on" do
        assert_equal @update[:published_on].to_date, @headline.published_on
      end

      should "set location" do
        assert_equal @update[:location], @headline.location
      end

      should "set country" do
        assert_equal @update[:country_id], @headline.country_id
      end

      should "set description" do
        assert_equal @update[:description], @headline.description
      end

      should "set headline type" do
        assert_equal @update[:headline_type], @headline.headline_type
      end

      should "set taggings" do
        assert_equal @update[:issue_ids], @headline.issue_ids
        assert_equal @update[:topic_ids], @headline.topic_ids
        assert_equal @update[:sector_ids], @headline.sector_ids
      end

      should "set state to pending approval" do
        assert @headline.pending?
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

    should "show headline" do
      get :show, id: @headline.to_param
      assert_response :success
      assert assigns(:headline)
    end

    should "get edit" do
      get :edit, id: @headline.to_param
      assert_response :success
      assert_select 'select#headline_headline_type', 1
    end

    should "update headline" do
      assert_no_difference 'Headline.count' do
        put :update, id: @headline, headline: @update
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
