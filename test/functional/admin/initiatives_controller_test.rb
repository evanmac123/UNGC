require 'test_helper'

class Admin::InitiativesControllerTest < ActionController::TestCase
  context "given a staff user" do
    setup do
      @staff_user = create_staff_user
      sign_in @staff_user
    end

    should "index" do
      initiatives = 2.times.map { create_initiative }
      get :index

      assert_response :success
      assert_template :index
      assert_equal 2, assigns(:initiatives).count
    end

    should "new" do
      get :new

      assert_response :success
      assert_not_nil assigns(:initiative)
      assert_template :new
    end

    context "creating a new initiative" do
      setup do
        assert_difference 'Initiative.count', 1 do
          post :create, {:initiative => {:name => 'Caring for the Climate'}}
        end
        @initiative = Initiative.find_by_name('Caring for the Climate')
      end

      should "create the initiative" do
        assert_redirected_to_index
        assert @initiative
      end

      should "show new template on failture" do
        Initiative.any_instance.stubs(:save).returns(false)
        post :create, initiative: {name: 'Wrong'}
        assert_template :new
      end
    end

    context "working with an existing initiative" do
      setup do
        @initiative = create_initiative :name => 'Caring for the Climate'
      end

      should "show" do
        get :show, id: @initiative
        assert_not_nil assigns(:initiative)
        assert_not_nil assigns(:signatories)

        assert_response :success
      end

      should "update" do
        assert_no_difference 'Initiative.count' do
          post :update, {:id => @initiative.id, :initiative => @initiative.attributes.merge(:name => 'Initiative changed!')}
        end
        assert_equal 'Initiative changed!', Initiative.find(@initiative.id).name
        assert_redirected_to_index
      end

      should "destroy" do
        assert_difference 'Initiative.count', -1 do
          delete :destroy, id: @initiative
        end
        assert_redirected_to_index
      end
    end
  end


end
