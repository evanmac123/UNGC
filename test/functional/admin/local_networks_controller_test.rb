require 'test_helper'

class Admin::LocalNetworksControllerTest < ActionController::TestCase
  def setup
    @staff_user = create_staff_user
    @local_network = create_local_network
    create_local_network_guest_organization
    sign_in @staff_user
  end

  test "should get index" do
    get :index, {}
    assert_response :success
    assert_not_nil assigns(:local_networks)
    assert_not_nil assigns(:local_network_guest)
  end

  test "should get new" do
    get :new, {}
    assert_response :success
  end

  test "should create local network" do
    assert_difference('LocalNetwork.count') do
      post :create, :local_network => { :name => 'Canada'}
    end

    assert_redirected_to admin_local_networks_path
  end

  test "should get edit" do
    get :edit, :id => @local_network.to_param
    assert_response :success
  end

  test "should get show" do
    get :show, :id => @local_network.to_param
    assert_response :success
    assert_template 'show'
  end

  should "update local network membership section and redirect to Network Management tab" do
    put :update, :id => @local_network.to_param, :local_network => { }, :section => 'membership'
    assert_equal 'membership', assigns(:section)
    assert_redirected_to admin_local_network_path(@local_network.id, :tab => 'membership')
  end

  test "should destroy local network" do
    assert_difference('LocalNetwork.count', -1) do
      delete :destroy, :id => @local_network.to_param
    end

    assert_redirected_to admin_local_networks_path
  end

  context "given a local network contact" do
    setup do
     create_local_network_with_report_recipient
     sign_in @network_contact
    end

    should "get edit" do
      get :edit, :id => @local_network.to_param
      assert_response :success
    end

    should "get edit for a specific section" do
      get :edit, :id => @local_network.to_param, :section => 'membership'
      assert_equal 'membership', assigns(:section)
      assert_equal 'edit_membership', assigns(:form_partial)
      assert_template :partial => '_edit_membership'
      assert_response :success
    end

    should "update local network membership section" do
      put :update, :id => @local_network.to_param, :local_network => { }, :section => 'membership'
      assert_equal 'membership', assigns(:section)
      assert_redirected_to admin_local_network_path(@local_network.id, :tab => 'membership')
    end

    should "update local network" do
      put :update, :id => @local_network.to_param, :local_network => { }
      assert_redirected_to admin_local_network_path(@local_network.id)
    end

    should "not edit another Local Network" do
      @another_network = create_local_network
      get :edit, :id => @another_network.to_param
      assert_redirected_to dashboard_path
    end

    should "not destroy another local network" do
      @another_network = create_local_network
      assert_difference('LocalNetwork.count', 0) do
        delete :destroy, :id => @another_network.to_param
      end
      assert_redirected_to dashboard_path
    end

  end

  should "handle contribution level attributes" do
    existing = @local_network.contribution_levels.add(
      description:'existing',
      amount:'$5')
    deleted = @local_network.contribution_levels.add(
      description:'deleted',
      amount:'$15')
    @local_network.save!

    post :update, id: @local_network.id, local_network: {
      contribution_levels: {
        id: @local_network.contribution_levels.id,
        levels: [
          existing.attributes.merge(description: 'updated'),
          {description:'new', amount:'$20'},
        ]
      }
    }

    levels = @local_network.reload.contribution_levels.reload
    assert_equal %w(updated new), levels.map(&:description)
  end

  should "edit local networks" do
    put :update, :id => @local_network.to_param, :local_network => {"membership_companies"=>"9999"}, :section => 'membership'
    @local_network.reload
    assert_equal 9999, @local_network.membership_companies
  end

  should "handle validation errors" do
    put :update, id: @local_network.to_param, local_network: {
      fees_amount_participant: "100",
      fees_amount_voluntary_private: "99.3", # should be integers
      fees_amount_voluntary_public: "0.7", # should be integers
      fees_participant: "true"
    }
    assert_match /Fees amount voluntary private must be an integer/, response.body
    assert_match /Fees amount voluntary public must be an integer/, response.body
  end

end
