require 'test_helper'

class LogoRequestsControllerTest < ActionController::TestCase
  def setup
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

    assert_redirected_to organization_path(assigns(:organization))
  end
  
  test "should destroy logo request" do
    assert_difference('LogoRequest.count', -1) do
      delete :destroy, :organization_id => @organization.id,
                       :id => @logo_request.to_param
    end

    assert_redirected_to organization_path(assigns(:organization))
  end
end
