require 'test_helper'

class LogoCommentsControllerTest < ActionController::TestCase
  def setup
    create_organization_type
    @organization = create_organization
    @contact = create_contact(:organization_id => @organization.id,
                              :email           => "dude@example.com")
    @publication = create_logo_publication
    @logo_request = create_logo_request(:organization_id => @organization.id,
                                        :contact_id      => @contact.id,
                                        :publication_id  => @publication.id)
  end
  
  test "should get new" do
    login_as @contact
    get :new, :logo_request_id => @logo_request.id
    assert_response :success
  end

  test "should create logo comment" do
    login_as @contact
    assert_difference('LogoComment.count') do
      post :create, :logo_request_id => @logo_request.id,
                    :logo_comment    => { :body       => "approve me, man",
                                          :attachment => fixture_file_upload('files/untitled.pdf', 'application/pdf') },
                    :commit          => LogoRequest::EVENT_REPLY
    end

    assert_redirected_to organization_logo_request_path(assigns(:logo_request).organization, assigns(:logo_request))
  end
end
