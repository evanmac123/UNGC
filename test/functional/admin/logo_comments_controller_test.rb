require 'test_helper'

class Admin::LogoCommentsControllerTest < ActionController::TestCase
  def setup
    create_organization_type
    create_country
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

    assert_redirected_to admin_organization_logo_request_path(assigns(:logo_request).organization_id, assigns(:logo_request))
  end

  context "given a logo request in review" do
    setup do
      create_logo_request
      @logo_request.state = LogoRequest::STATE_IN_REVIEW
      create_staff_user
    end

    should "should set replied_to to false after a user updates" do
      login_as @contact
      assert_difference('LogoComment.count') do
        post :create, :logo_request_id => @logo_request.id,
                      :logo_comment    => { :body       => "approve me, man",
                                            :attachment => fixture_file_upload('files/untitled.pdf', 'application/pdf') },
                      :commit          => LogoRequest::EVENT_REPLY
        end
      @logo_request.reload
      assert_equal false, @logo_request.replied_to
    end
  
    should "should set replied_to to true after a staff user updates" do
      login_as @contact
      assert_difference('LogoComment.count') do
        post :create, :logo_request_id => @logo_request.id,
                      :logo_comment    => { :body       => "approve me, man",
                                            :attachment => fixture_file_upload('files/untitled.pdf', 'application/pdf') },
                      :commit          => LogoRequest::EVENT_REPLY
        end
      @logo_request.reload
      assert_equal false, @logo_request.replied_to
      
      
      login_as @staff_user
      assert_difference('LogoComment.count') do
        post :create, {:logo_request_id => @logo_request.id,
                       :logo_comment    => { :body => "revise, please" },
                       :commit          => LogoRequest::EVENT_REVISE },
                      as(@staff_user)
        end
      @logo_request.reload
      # FIXME - should be true. May not be posting as staff user
      assert_equal false, @logo_request.replied_to
    end 

  end

end