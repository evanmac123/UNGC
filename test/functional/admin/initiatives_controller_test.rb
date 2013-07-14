require 'test_helper'

class Admin::InitiativesControllerTest < ActionController::TestCase
  context "given a staff user" do
    setup do
      @staff_user = create_staff_user
      sign_in @staff_user
    end

    context "creating a new initiative" do
      setup do
        assert_difference 'Initiative.count', 1 do
          put :create, {:initiative => {:name => 'Caring for the Climate'}}
        end
        @initiative = Initiative.find_by_name('Caring for the Climate')
      end

      should "create the initiative" do
        assert_redirected_to_index
        assert @initiative
      end
    end

    context "working with an existing initiative" do
      setup do
        @initiative = create_initiative :name => 'Caring for the Climate'
      end

      should "update" do
        assert_no_difference 'Event.count' do
          post :update, {:id => @initiative.id, :initiative => @initiative.attributes.merge(:name => 'Initiative changed!')}
        end
        assert_equal 'Initiative changed!', Initiative.find(@initiative.id).name
        assert_redirected_to_index
      end
    end
  end


end
