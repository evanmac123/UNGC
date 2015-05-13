require 'test_helper'

class Admin::EventsControllerTest < ActionController::TestCase
  setup do
    @staff_user = create_staff_user

    @country = create_country(name: 'USA')
    @contact = create_contact
    @topic = create_topic
    @issue = create_issue
    @sector = create_sector

    starts_at = Time.new(2015, 06, 15, 19, 0, 0)
    ends_at = Time.new(2015, 06, 15, 22, 0, 0)

    @params = {
      title: 'New Website Launch',
      description: 'Join the UN Global Compact as we celebrate...',
      starts_at: starts_at,
      ends_at: ends_at,
      is_all_day: false.to_s,
      is_online: false.to_s,
      location: 'New York, NY',
      country_id: @country.id.to_s,
      is_invitation_only: false.to_s,
      priority: :tier1.to_s,
      contact: @contact.id.to_s,
      thumbnail_image: fixture_file_upload('files/untitled.jpg', 'image/jpeg'),
      banner_image: fixture_file_upload('files/untitled.jpg', 'image/jpeg'),
      call_to_action_1_title: 'Contact Us an Invitation',
      call_to_action_1_link: 'http://unglobalbompact.org/about/contact',
      call_to_action_2_title: 'Download a Poster',
      call_to_action_2_link: 'http://unglobalbompact.org/downloads',
      overview_description: 'Over the past couple months...',
      topic_ids: [@topic.id.to_s],
      issue_ids: [@issue.id.to_s],
      sector_ids: [@sector.id.to_s]
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
            post :create, event_form: @params
          end
        end

        should 'create an event' do
          @event = Event.last

          assert_equal @params[:title], @event.title
          assert_equal @params[:description], @event.description
          assert_equal @params[:starts_at], @event.starts_at
          assert_equal @params[:ends_at], @event.ends_at
          assert_equal @params[:is_all_day], @event.is_all_day
          assert_equal @params[:is_online], @event.is_online
          assert_equal @params[:location], @event.location
          assert_equal @params[:country_id], @event.country_id
          assert_equal @params[:is_invitation_only], @event.is_invitation_only
          assert_equal @params[:priority], @event.priority
          assert_equal @params[:contact_id], @event.contact_id
          assert_equal Paperclip::Attachment, @event.thumbnail_image.class
          assert_equal Paperclip::Attachment, @event.banner_image.class
          assert_equal @params[:call_to_action_1_title], @event.call_to_action_1_title
          assert_equal @params[:call_to_action_1_link], @event.call_to_action_1_link
          assert_equal @params[:call_to_action_2_title], @event.call_to_action_2_title
          assert_equal @params[:call_to_action_2_link], @event.call_to_action_2_link
          assert_equal @params[:overview_description], @event.overview_description
          assert @event.pending?
          assert_equal @params[:topic_ids], @event.topic_ids
          assert_equal @params[:issue_ids], @event.issue_ids
          assert_equal @params[:sector_ids], @event.sector_ids

          assert_redirected_to_index
        end
      end

      context 'with invalid params' do
        # TODO: Determine what params would be invalid.
      end
    end

    context 'GET /admin/events/:id' do
      setup do
        @event = create_event
      end

      should 'retrieve an event' do
        assert_response :success
        assert assigns(:event), 'Instance variable "event" not assigned.'
      end
    end

    context 'PUT /admin/events/:id' do
      context 'with valid params' do
        setup do
          @event = create_event

          assert_no_difference 'Event.count' do
            put :update, id: @event.id, event_form: @params
          end
        end

        should 'update an event' do
          assert_equal @params[:title], @event.title
          assert_equal @params[:description], @event.description
          assert_equal @params[:starts_at], @event.starts_at
          assert_equal @params[:ends_at], @event.ends_at
          assert_equal @params[:is_all_day], @event.is_all_day
          assert_equal @params[:is_online], @event.is_online
          assert_equal @params[:location], @event.location
          assert_equal @params[:country_id], @event.country_id
          assert_equal @params[:is_invitation_only], @event.is_invitation_only
          assert_equal @params[:priority], @event.priority
          assert_equal @params[:contact_id], @event.contact_id
          assert_equal Paperclip::Attachment, @event.thumbnail_image.class
          assert_equal Paperclip::Attachment, @event.banner_image.class
          assert_equal @params[:call_to_action_1_title], @event.call_to_action_1_title
          assert_equal @params[:call_to_action_1_link], @event.call_to_action_1_link
          assert_equal @params[:call_to_action_2_title], @event.call_to_action_2_title
          assert_equal @params[:call_to_action_2_link], @event.call_to_action_2_link
          assert_equal @params[:overview_description], @event.overview_description
          assert @event.pending?
          assert_equal @params[:topic_ids], @event.topic_ids
          assert_equal @params[:issue_ids], @event.issue_ids
          assert_equal @params[:sector_ids], @event.sector_ids

          assert_redirected_to_index
        end
      end
    end

    context 'POST /admin/events/:id/approve' do
      setup do
        @event = create_event

        assert_no_difference 'Event.count' do
          post :approve, id: @event.id
        end

        @event.reload
      end

      should 'approve the event' do
        assert @event.approved?
        assert_contains Event.approved, @event # TODO: Remove if redundant.

        assert_redirected_to_index
      end

      should 'set updated_by to the staff member' do
        assert_equal @staff_user.id, @event.updated_by_id
      end
    end

    context 'POST /admin/events/:id/revoke' do
      setup do
        @event = create_event
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

        assert_redirected_to_index
      end

      should 'set updated_by to the staff member' do
        assert_equal @staff_user.id, @event.updated_by_id
      end
    end

    context 'DELETE /admin/events/:id' do
      setup do
        @event = create_event
      end

      should 'destroy event' do
        assert_difference('Event.count', -1) do
          delete :destroy, id: @event.id
        end

        assert_redirected_to_index
      end
    end

    context 'GET /admin/events' do
      setup do
        3.times { create_event }
      end

      should 'list events' do
        assert_response :success
        assert assigns(:events), 'Instance variable "events" not assigned.'
      end
    end
  end
end
