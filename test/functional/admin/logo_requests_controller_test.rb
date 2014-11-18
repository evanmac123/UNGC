require 'test_helper'

class Admin::LogoRequestsControllerTest < ActionController::TestCase
  context "given a pending organization" do
    setup do
      create_organization_type
      create_country
      @organization = create_organization
      @contact = create_contact(:organization_id => @organization.id,
                                :email           => "dude@example.com")
      @publication = create_logo_publication
      @logo_request = create_logo_request(:organization_id => @organization.id,
                                          :contact_id      => @contact.id,
                                          :publication_id  => @publication.id)
      sign_in @contact
    end

    should "not get new form" do
      get :new, :organization_id => @organization.id
      assert_redirected_to admin_organization_path(@organization.id)
    end
  end

  context "given an approved organization" do
    setup do
      create_organization_type
      create_country
      @organization = create_organization
      @organization.approve!
      @contact = create_contact(:organization_id => @organization.id,
                                :email           => "dude@example.com")
      @publication = create_logo_publication
      @logo_request = create_logo_request(:organization_id => @organization.id,
                                          :contact_id      => @contact.id,
                                          :publication_id  => @publication.id)
      sign_in @contact
    end

    should "get new form" do
      get :new, :organization_id => @organization.id
      assert_response :success
      assert_template 'new'
    end

    should "create logo request" do
      assert_difference('LogoRequest.count') do
        comment_attributes = {:body       =>"comment",
                              :attachment => fixture_file_upload('files/untitled.pdf', 'application/pdf')}

        post :create, :organization_id => @organization.id,
                      :logo_request => { :contact_id     => @contact.id,
                                         :purpose        => 'Report',
                                         :publication_id => @publication.id,
                                         :logo_comments_attributes=>{"0"=>comment_attributes} }
      end

      assert_template 'confirmation'
    end

    should "destroy logo request" do
      assert_difference('LogoRequest.count', -1) do
        delete :destroy, :organization_id => @organization.id,
                         :id => @logo_request.to_param
      end

      assert_redirected_to admin_organization_path(assigns(:organization).id)
    end
  end

  context "given an approved logo request" do
    setup do
      create_approved_logo_request
      @organization.approve!
      sign_in @organization_user
    end

    should "show a logo request page" do
      get :show, :id              => @logo_request.id,
                 :organization_id => @logo_request.organization.id
      assert_response :success
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
      @organization.approve!
      @logo_request.accept
      sign_in @organization_user
    end

    should "allow download of logo" do
      get :download, :id              => @logo_request.id,
                     :organization_id => @logo_request.organization.id,
                     :logo_file_id    => LogoFile.first.id
      assert_response :success
    end

    should "allow updates" do
      patch :update, :id              => @logo_request.id,
                     :organization_id => @logo_request.organization.id,
                     :logo_request    => { :purpose => 'New Purpose' },
                     :commit          => "Save logos"
      assert_redirected_to new_admin_logo_request_logo_comment_path(@logo_request)
      @logo_request.reload
      assert_equal 'New Purpose', @logo_request.purpose

    end

  end

  context "approval actions" do
    setup do
      create_organization_and_user
      @organization.approve!
      sign_in @organization_user
      @requests = stub(includes: stub(order: stub(paginate: stub(each: [], total_pages: 0))))
    end

    should "get approved requests" do
      LogoRequest.expects(:approved_or_accepted).returns(@requests)
      get :approved
      assert_response :success
    end

    should "get rejected requests" do
      LogoRequest.expects(:rejected).returns(@requests)
      get :rejected
      assert_response :success
    end

    should "get pending_review requests" do
      LogoRequest.expects(:pending_review).returns(@requests)
      Signing.expects(:latest_contribution_update).returns(Time.now)
      get :pending_review
      assert_response :success
    end

    should "get in_review requests" do
      LogoRequest.expects(:in_review).returns(@requests)
      get :in_review
      assert_response :success
    end

    should "get unreplied requests" do
      LogoRequest.expects(:unreplied).returns(@requests)
      get :unreplied
      assert_response :success
      assert_template :in_review
    end
  end

  should "show the index" do
    sign_in create_staff_user
    get :index
  end

end
