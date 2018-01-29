require 'test_helper'

class Admin::EventsControllerTest < ActionController::TestCase
  setup do
    @staff_user = create_staff_user

    @country = create(:country, name: 'USA')
    @contact = create(:contact)
    @sponsor = create(:sponsor)
    @topic = create(:topic)
    @issue = create(:issue)
    @sector = create(:sector)
    @sdg = create(:sustainable_development_goal)

    @starts_at = DateTime.new(2015, 06, 15, 19, 0, 0)
    @ends_at = DateTime.new(2015, 06, 15, 22, 0, 0)

    @params = {
      title: 'New Website Launch',
      description: 'Join the UN Global Compact as we celebrate...',
      'starts_at(1i)' => @starts_at.strftime('%Y'),
      'starts_at(2i)' => @starts_at.strftime('%m'),
      'starts_at(3i)' => @starts_at.strftime('%d'),
      'starts_at(4i)' => @starts_at.strftime('%H'),
      'starts_at(5i)' => @starts_at.strftime('%M'),
      'ends_at(1i)' => @ends_at.strftime('%Y'),
      'ends_at(2i)' => @ends_at.strftime('%m'),
      'ends_at(3i)' => @ends_at.strftime('%d'),
      'ends_at(4i)' => @ends_at.strftime('%H'),
      'ends_at(5i)' => @ends_at.strftime('%M'),
      is_all_day: false,
      is_online: false,
      location: 'New York, NY',
      country_id: @country.id,
      is_invitation_only: false,
      priority: 'tier1',
      contact_id: @contact.id,
      thumbnail_image: fixture_file_upload('files/untitled.jpg', 'image/jpeg'),
      banner_image: fixture_file_upload('files/untitled.jpg', 'image/jpeg'),
      call_to_action_1_label: 'Contact Us an Invitation',
      call_to_action_1_url: 'http://unglobalbompact.org/about/contact',
      call_to_action_2_label: 'Download a Poster',
      call_to_action_2_url: 'http://unglobalbompact.org/downloads',
      programme_description: 'Over the past couple months...',
      sponsor_ids: [@sponsor.id],
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

    context 'POST /admin/events' do
      context 'with valid params' do
        setup do
          assert_difference 'Event.count' do
            post :create, event: @params
          end

          @event = Event.last
        end

        should 'set title' do
          assert_equal @params[:title], @event.title
        end

        should 'set description' do
          assert_equal @params[:description], @event.description
        end

        should 'set starts_at' do
          assert_equal @starts_at, @event.starts_at
        end

        should 'set ends_at' do
          assert_equal @ends_at, @event.ends_at
        end

        should 'set is_all_day' do
          assert_equal @params[:is_all_day], @event.is_all_day
        end

        should 'set is_online' do
          assert_equal @params[:is_online], @event.is_online
        end

        should 'set location' do
          assert_equal @params[:location], @event.location
        end

        should 'set country_id' do
          assert_equal @params[:country_id], @event.country_id
        end

        should 'set is_invitation_only' do
          assert_equal @params[:is_invitation_only], @event.is_invitation_only
        end

        should 'set priority' do
          assert_equal @params[:priority], @event.priority
        end

        should 'set contact_id' do
          assert_equal @params[:contact_id], @event.contact_id
        end

        should 'set thumbnail_image' do
          assert @event.thumbnail_image.file?
        end

        should 'set banner_image' do
          assert @event.banner_image.file?
        end

        should 'set call_to_action_1_label' do
          assert_equal @params[:call_to_action_1_label], @event.call_to_action_1_label
        end

        should 'set call_to_action_1_url' do
          assert_equal @params[:call_to_action_1_url], @event.call_to_action_1_url
        end

        should 'set call_to_action_2_label' do
          assert_equal @params[:call_to_action_2_label], @event.call_to_action_2_label
        end

        should 'set call_to_action_2_url' do
          assert_equal @params[:call_to_action_2_url], @event.call_to_action_2_url
        end

        should 'set programme_description' do
          assert_equal @params[:programme_description], @event.programme_description
        end

        should 'set sponsor IDs' do
          assert_equal @params[:sponsor_ids], @event.sponsor_ids
        end

        should 'set approval' do
          assert @event.pending?
        end

        should 'set topic IDs' do
          assert_equal @params[:topic_ids], @event.topic_ids
        end

        should 'set issue IDs' do
          assert_equal @params[:issue_ids], @event.issue_ids
        end

        should 'set sector IDs' do
          assert_equal @params[:sector_ids], @event.sector_ids
        end

        should 'set sustainale development goal IDs' do
          assert_equal @params[:sustainable_development_goal_ids], @event.sustainable_development_goal_ids
        end

        should 'redirects to index' do
          assert_redirected_to_index
        end
      end

      context 'with invalid params' do
        # TODO: Determine what params would be invalid.
      end
    end

    context 'GET /admin/events/:id' do
      setup do
        @event = create(:event)
        get :show, id: @event.id
      end

      should 'retrieve an event' do
        assert_response :success
        assert assigns(:event), 'Instance variable "event" not assigned.'
      end
    end

    context 'GET /admin/events/:id/edit' do
      setup do
        @event = create(:event)
        get :edit, id: @event.id
      end

      should 'retrieve an event' do
        assert_response :success
      end
    end

    context 'PUT /admin/events/:id' do
      context 'with valid params' do
        setup do
          @event = create(:event)

          assert_no_difference 'Event.count' do
            put :update, id: @event.id, event: @params
          end

          @event.reload
        end

        should 'set title' do
          assert_equal @params[:title], @event.title
        end

        should 'set description' do
          assert_equal @params[:description], @event.description
        end

        should 'set starts_at' do
          assert_equal @starts_at, @event.starts_at
        end

        should 'set ends_at' do
          assert_equal @ends_at, @event.ends_at
        end

        should 'set is_all_day' do
          assert_equal @params[:is_all_day], @event.is_all_day
        end

        should 'set is_online' do
          assert_equal @params[:is_online], @event.is_online
        end

        should 'set location' do
          assert_equal @params[:location], @event.location
        end

        should 'set country_id' do
          assert_equal @params[:country_id], @event.country_id
        end

        should 'set priority' do
          assert_equal @params[:priority], @event.priority
        end

        should 'set contact_id' do
          assert_equal @params[:contact_id], @event.contact_id
        end

        should 'set thumbnail_image' do
          assert @event.thumbnail_image.file?
        end

        should 'set banner_image' do
          assert @event.banner_image.file?
        end

        should 'set call_to_action_1_label' do
          assert_equal @params[:call_to_action_1_label], @event.call_to_action_1_label
        end

        should 'set call_to_action_1_url' do
          assert_equal @params[:call_to_action_1_url], @event.call_to_action_1_url
        end

        should 'set call_to_action_2_label' do
          assert_equal @params[:call_to_action_2_label], @event.call_to_action_2_label
        end

        should 'set call_to_action_2_url' do
          assert_equal @params[:call_to_action_2_url], @event.call_to_action_2_url
        end

        should 'set programme_description' do
          assert_equal @params[:programme_description], @event.programme_description
        end

        should 'set sponsor IDs' do
          assert_equal @params[:sponsor_ids], @event.sponsor_ids
        end

        should 'set approval' do
          assert @event.pending?
        end

        should 'set topic IDs' do
          assert_equal @params[:topic_ids], @event.topic_ids
        end

        should 'set issue IDs' do
          assert_equal @params[:issue_ids], @event.issue_ids
        end

        should 'set sector IDs' do
          assert_equal @params[:sector_ids], @event.sector_ids
        end

        should 'set sustainale development goal IDs' do
          assert_equal @params[:sustainable_development_goal_ids], @event.sustainable_development_goal_ids
        end

        should 'redirects to index' do
          assert_redirected_to_index
        end
      end

      context 'with no topic IDs' do
        should 'remove all topics' do
          @topic_ids = 2.times.map { create(:topic).id }
          @event = create(:event, topic_ids: @topic_ids)

          assert_difference '@event.topics.count', -2 do
            put :update, id: @event.id, event: { topic_ids: [] }
          end
        end
      end

      context 'with no sponsor IDs' do
        should 'remove all sponsors' do
          @sponsor_ids = 2.times.map { create(:sponsor).id }
          @event = create(:event, sponsor_ids: @sponsor_ids)

          assert_difference '@event.sponsors.count', -2 do
            put :update, id: @event.id, event: { sponsor_ids: [] }
          end
        end
      end

      context 'with no sustainable development goal IDs' do
        should 'remove all sustainable development goals' do
          @sdg = 2.times.map { create(:sustainable_development_goal).id }
          @event = create(:event, sustainable_development_goal_ids: @sdg)

          assert_difference '@event.sustainable_development_goals.count', -2 do
            put :update, id: @event.id, event: { sustainable_development_goal_ids: [] }
          end
        end
      end
    end

    context 'POST /admin/events/:id/approve' do
      setup do
        @event = create(:event)

        assert_no_difference 'Event.count' do
          post :approve, id: @event.id
        end

        @event.reload
      end

      should 'approve the event' do
        assert @event.approved?
        assert_contains Event.approved, @event # TODO: Remove if redundant.
      end

      should 'redirects to index' do
        assert_redirected_to_index
      end

      should 'set updated_by to the staff member' do
        assert_equal @staff_user.id, @event.updated_by_id
      end
    end

    context 'POST /admin/events/:id/revoke' do
      setup do
        @event = create(:event)
        # clear updated_by_id so we're sure it gets set.
        @event.update_attribute :updated_by_id, nil
        @event.as_user(@staff_user).approve!

        assert_no_difference 'Event.count' do
          post :revoke, id: @event.id
        end

        @event.reload
      end

      should 'revoke approval for the event' do
        assert @event.revoked?
        assert_does_not_contain Event.approved, @event # TODO: Remove if redundant.
      end

      should 'redirects to index' do
        assert_redirected_to_index
      end

      should 'set updated_by to the staff member' do
        assert_equal @staff_user.id, @event.updated_by_id
      end
    end

    context 'DELETE /admin/events/:id' do
      context 'given an event with no associations' do
        setup do
          @event = create(:event)

          assert_difference('Event.count', -1) do
            delete :destroy, id: @event.id
          end
        end

        should 'destroy event' do
          assert_not Event.exists? @event
        end

        should 'redirects to index' do
          assert_redirected_to_index
        end
      end

      context 'given an event with a tagging associations' do
        setup do
          post :create, event: @params
          @event = Event.last

          assert_difference('Event.count', -1) do
            delete :destroy, id: @event.id
          end
        end

        should 'destroy event' do
          assert_not Event.exists? @event
        end

        should 'redirects to index' do
          assert_redirected_to_index
        end
      end
    end

    context 'GET /admin/events' do
      setup do
        3.times { create(:event) }

        get :index
      end

      should 'list events' do
        assert_response :success
        assert assigns(:paged_events), 'Instance variable "paged_events" not assigned.'
      end
    end
  end
end
