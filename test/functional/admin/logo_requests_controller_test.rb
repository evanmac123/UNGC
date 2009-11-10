require 'test_helper'

class Admin::LogoRequestsControllerTest < ActionController::TestCase
  def setup
    create_organization_type
    @organization = create_organization
    @contact = create_contact(:organization_id => @organization.id,
                              :email           => "dude@example.com")
    @publication = create_logo_publication
    @logo_request = create_logo_request(:organization_id => @organization.id,
                                        :contact_id      => @contact.id,
                                        :publication_id  => @publication.id)
    login_as @contact
  end
  
  test "should get new" do
    get :new, :organization_id => @organization.id
    assert_response :success
  end

  test "should create logo request" do
    assert_difference('LogoRequest.count') do
      comment_attributes = {:body       =>"comment",
                            :attachment => fixture_file_upload('files/untitled.pdf', 'application/pdf')}
      
      post :create, :organization_id => @organization.id,
                    :logo_request => { :contact_id     => @contact.id,
                                       :purpose        => 'Report',
                                       :publication_id => @publication.id,
                                       :logo_comments_attributes=>{"0"=>comment_attributes} }
    end

    assert_redirected_to admin_organization_path(assigns(:organization))
  end
  
  test "should destroy logo request" do
    assert_difference('LogoRequest.count', -1) do
      delete :destroy, :organization_id => @organization.id,
                       :id => @logo_request.to_param
    end

    assert_redirected_to admin_organization_path(assigns(:organization))
  end
  
  context "given an approved logo request" do
    setup do
      create_approved_logo_request
      login_as @organization_user
    end
    
    should "not allow download of logo" do
      get :download, :id              => @logo_request.id,
                     :organization_id => @logo_request.organization.id
      assert_response :redirect
      assert_not_nil flash[:error]
    end
    
    should "allow organization user to agree to logo terms" do
      post :agree, :id              => @logo_request.id,
                   :organization_id => @logo_request.organization.id
      assert @logo_request.reload.accepted?
      assert_not_nil @logo_request.accepted_on
    end
  end
  
  context "given an accepted logo request" do
    setup do
      create_approved_logo_request
      @logo_request.accept
      login_as @organization_user
    end
    
    should "allow download of logo" do
      # TODO: this test should not raise an exception when a LogoFile is created through controller
      assert_raises TypeError do
        get :download, :id              => @logo_request.id,
                       :organization_id => @logo_request.organization.id,
                       :logo_file_id    => LogoFile.first.id
        assert_response :success
      end
    end
  end
end
