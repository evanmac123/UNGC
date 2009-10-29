require 'test_helper'

class Admin::EventsControllerTest < ActionController::TestCase
  context "given a staff user" do
    setup do
      @staff_user = create_staff_user
    end

    context "creating a new event" do
      setup do
        @attributes = new_event(:title => 'This is my event', :starts_on => (Date.today - 5), :ends_on => Date.today).attributes
        assert_difference 'Event.count', 1 do
          put :create, {:event => @attributes}, as(@staff_user)
        end
        @event = Event.find_by_title('This is my event')
      end

      should "create the envet" do
        assert_redirected_to_index
        assert @event
      end
      
      should "be pending approval" do
        assert @event.pending?
      end
      
      context "then approve it" do
        setup do
          assert_no_difference 'Event.count' do
            post :approve, {:id => @event.id}, as(@staff_user)
          end
          @event.reload
        end

        should "approve the event" do
          assert_redirected_to_index
          assert @event.approved?
          assert_contains Event.approved, @event
        end
        
        context "but then revoke it" do
          setup do
            assert_no_difference 'Event.count' do
              post :revoke, {:id => @event.id}, as(@staff_user)
            end
            @event.reload
          end

          should "revoke approval of the event" do
            assert_redirected_to_index
            assert @event.revoked?
            assert_does_not_contain Event.approved, @event
          end
        end
      end
    end

    context "working with an existing event" do
      setup do
        @event = create_event :title => 'This is my event', :starts_on => (Date.today - 5), :ends_on => Date.today
      end

      should "update" do
        assert_no_difference 'Event.count' do
          post :update, {:id => @event.id, :event => @event.attributes.merge(:title => 'Event changed!')}, as(@staff_user)
        end
        assert_equal 'Event changed!', Event.find(@event.id).title
        assert_redirected_to_index
      end
    end
  end
  
  
end
