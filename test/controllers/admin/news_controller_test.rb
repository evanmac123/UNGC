require 'test_helper'

class Admin::NewsControllerTest < ActionController::TestCase
  setup do
    @staff_user = create_staff_user

    @country = create(:country, name: 'USA')
    @topic = create(:topic)
    @issue = create(:issue)
    @sector = create(:sector)
    @sdg = create(:sustainable_development_goal)

    @params = {
      title: 'New Website Launch',
      location: 'New York, NY',
      country_id: @country.id,
      description: 'Join the UN Global Compact as we celebrate...',
      published_on: '2015-06-15',
      headline_type: 'press_release',
      topic_ids: [@topic.id],
      issue_ids: [@issue.id],
      sector_ids: [@sector.id],
      sustainable_development_goal_ids: [@sdg.id]
    }
  end

  context "given a staff user" do
    setup do
      sign_in @staff_user
    end

    context 'POST /admin/headlines' do
      context 'with valid params' do
        setup do
          assert_difference 'Headline.count' do
            post :create, headline: @params
          end

          @headline = Headline.last
        end

        should "set title" do
          assert_equal @params[:title], @headline.title
        end

        should "set location" do
          assert_equal @params[:location], @headline.location
        end

        should "set country" do
          assert_equal @params[:country_id], @headline.country_id
        end

        should "set description" do
          assert_equal @params[:description], @headline.description
        end

        should "set published on" do
          assert_equal @params[:published_on].to_date, @headline.published_on
        end

        should "set headline type" do
          assert_equal @params[:headline_type], @headline.headline_type
        end

        should "set approval" do
          assert @headline.pending?
        end

        should "set topic IDs" do
          assert_equal @params[:topic_ids], @headline.topic_ids
        end

        should "set issue IDs" do
          assert_equal @params[:issue_ids], @headline.issue_ids
        end

        should "set sector IDs" do
          assert_equal @params[:sector_ids], @headline.sector_ids
        end

        should 'set sustainale development goal IDs' do
          assert_equal @params[:sustainable_development_goal_ids], @headline.sustainable_development_goal_ids
        end

        should "redirect to index" do
          assert_redirected_to_index
        end
      end

      context 'with invalid params' do
        # TODO: Determine what params would be invalid.
      end
    end

    context 'GET /admin/headlines/:id' do
      setup do
        @headline = create(:headline)
        get :show, id: @headline.id
      end

      should 'retrieve an headline' do
        assert_response :success
        assert assigns(:headline), 'Instance variable "headline" not assigned.'
      end
    end

    context 'GET /admin/headlines/:id/edit' do
      setup do
        @headline = create(:headline)
        get :edit, id: @headline.id
      end

      should 'retrieve an headline' do
        assert_response :success
      end
    end

    context 'PUT /admin/headlines/:id' do
      context 'with valid params' do
        setup do
          @headline = create(:headline)

          assert_no_difference 'Headline.count' do
            put :update, id: @headline.id, headline: @params
          end

          @headline.reload
        end

        should "set title" do
          assert_equal @params[:title], @headline.title
        end

        should "set location" do
          assert_equal @params[:location], @headline.location
        end

        should "set country" do
          assert_equal @params[:country_id], @headline.country_id
        end

        should "set description" do
          assert_equal @params[:description], @headline.description
        end

        should "set published on" do
          assert_equal @params[:published_on].to_date, @headline.published_on
        end

        should "set headline type" do
          assert_equal @params[:headline_type], @headline.headline_type
        end

        should "set approval" do
          assert @headline.pending?
        end

        should "set topic IDs" do
          assert_equal @params[:topic_ids], @headline.topic_ids
        end

        should "set issue IDs" do
          assert_equal @params[:issue_ids], @headline.issue_ids
        end

        should "set sector IDs" do
          assert_equal @params[:sector_ids], @headline.sector_ids
        end

        should 'set sustainale development goal IDs' do
          assert_equal @params[:sustainable_development_goal_ids], @headline.sustainable_development_goal_ids
        end

        should "redirect to index" do
          assert_redirected_to_index
        end
      end

      context 'with no topic IDs' do
        should 'remove all topics' do
          @topic_ids = 2.times.map { create(:topic).id }
          @headline = create(:headline, topic_ids: @topic_ids)

          assert_difference '@headline.topics.count', -2 do
            put :update, id: @headline.id, headline: { topic_ids: [] }
          end
        end
      end

      context 'with no sustainable development goal IDs' do
        should 'remove all sustainable development goals' do
          @sdg = 2.times.map { create(:sustainable_development_goal).id }
          @headline = create(:headline, sustainable_development_goal_ids: @sdg)

          assert_difference '@headline.sustainable_development_goals.count', -2 do
            put :update, id: @headline.id, headline: { sustainable_development_goal_ids: [] }
          end
        end
      end
    end

    context 'POST /admin/headlines/:id/approve' do
      setup do
        @headline = create(:headline)

        assert_no_difference 'Headline.count' do
          post :approve, id: @headline.id
        end

        @headline.reload
      end

      should 'approve the headline' do
        assert @headline.approved?
        assert_contains Headline.approved, @headline # TODO: Remove if redundant.
      end

      should 'redirects to index' do
        assert_redirected_to_index
      end

      should 'set updated_by to the staff member' do
        assert_equal @staff_user.id, @headline.updated_by_id
      end
    end

    context 'POST /admin/headlines/:id/revoke' do
      setup do
        @headline = create(:headline)
        # clear updated_by_id so we're sure it gets set.
        @headline.update_attribute :updated_by_id, nil
        @headline.as_user(@staff_user).approve!

        assert_no_difference 'Headline.count' do
          post :revoke, id: @headline.id
        end

        @headline.reload
      end

      should 'revoke approval for the headline' do
        assert @headline.revoked?
        assert_does_not_contain Headline.approved, @headline # TODO: Remove if redundant.
      end

      should 'redirects to index' do
        assert_redirected_to_index
      end

      should 'set updated_by to the staff member' do
        assert_equal @staff_user.id, @headline.updated_by_id
      end
    end

    context 'DELETE /admin/headlines/:id' do
      context 'given an headline with no associations' do
        setup do
          @headline = create(:headline)

          assert_difference('Headline.count', -1) do
            delete :destroy, id: @headline.id
          end
        end

        should 'destroy headline' do
          assert_not Headline.exists? @headline
        end

        should 'redirects to index' do
          assert_redirected_to_index
        end
      end

      context 'given an headline with a tagging associations' do
        setup do
          post :create, headline: @params
          @headline = Headline.last

          assert_difference('Headline.count', -1) do
            delete :destroy, id: @headline.id
          end
        end

        should 'destroy headline' do
          assert_not Headline.exists? @headline
        end

        should 'redirects to index' do
          assert_redirected_to_index
        end
      end
    end

    context 'GET /admin/headlines' do
      setup do
        3.times { create(:headline) }

        get :index
      end

      should 'list headlines' do
        assert_response :success
        assert assigns(:paged_headlines), 'Instance variable "paged_headlines" not assigned.'
      end
    end
  end
end
