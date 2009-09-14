require 'test_helper'

class LogoCommentsControllerTest < ActionController::TestCase
  def setup
    @organization = create_organization
    @contact = create_contact(:organization_id => @organization.id,
                              :email           => "dude@example.com")
    @publication = create_logo_publication
    @logo_request = create_logo_request(:organization_id => @organization.id,
                                        :contact_id      => @contact.id,
                                        :publication_id  => @publication.id)
  end
  
  test "should get new" do
    get :new, :logo_request_id => @logo_request.id
    assert_response :success
  end

  test "should create logo comment" do
    login_as @contact
    assert_difference('LogoComment.count') do
      post :create, :logo_request_id => @logo_request.id,
                    :logo_comment    => { :body => "approve me, man" },
                    :commit          => LogoRequest::EVENT_REPLY
    end

    assert_redirected_to organization_logo_request_path(assigns(:logo_request).organization, assigns(:logo_request))
  end
end
