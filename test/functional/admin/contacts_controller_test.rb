require 'test_helper'

class Admin::ContactsControllerTest < ActionController::TestCase
  def setup
    create_organization_type
    @organization = create_organization
    @contact = create_contact(:organization_id => @organization.id,
                              :email           => "dude@example.com")

    login_as(@contact)
  end
  
  test "should get new" do
    get :new, :organization_id => @organization.id
    assert_response :success
  end

  test "should create contact" do
    assert_difference('Contact.count') do
      post :create, :organization_id => @organization.id,
                    :contact => { :first_name => 'Dude',
                                  :last_name  => 'Smith',
                                  :login      => 'test',
                                  :password   => 'test' }
    end

    assert_redirected_to admin_organization_path(assigns(:organization).id)
  end
  
  test "should get edit" do
    get :edit, :organization_id => @organization.id,
               :id => @contact.to_param
    assert_response :success
  end
  
  test "should update contact" do
    put :update, :organization_id => @organization.id,
                 :id => @contact.to_param, :contact => { :login    => 'aaa',
                                                         :password => "password" }
    assert_redirected_to admin_organization_path(assigns(:organization).id)
  end

  test "should destroy contact" do
    @contact_to_be_deleted = create_contact(:organization_id => @organization.id,
                                            :email           => "dude2@example.com")
    assert_difference('Contact.count', -1) do
      delete :destroy, :organization_id => @organization.id,
                       :id => @contact_to_be_deleted.to_param
    end

    assert_redirected_to admin_organization_path(assigns(:organization).id)
  end
end
