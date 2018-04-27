require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  context 'given a UNGC staff member' do
    setup do
      create_organization_and_user
      add_organization_data(@organization, @organization_user)
      sign_in create_staff_user
    end

    should 'get the dashboard page' do
      # now get the dashboard
      get :dashboard
      assert_response :success
      assert_template 'admin/dashboard_ungc'
    end
  end

  context 'given a approved organization member' do
    setup do
      user = create_organization_and_user
      @organization.update_attribute :state, 'approved'
      add_organization_data(@organization, user)
      sign_in user
    end

    should 'get the dashboard page' do
      get :dashboard
      assert_response :success
      assert_template 'admin/dashboard_organization'
    end
  end

  context 'given a pending organization member' do
    setup do
      user = create_organization_and_user
      create(:comment,
             commentable: @organization,
             commentable_type: 'Organization',
             contact: @organization_user)
      sign_in user
    end

    should 'get the dashboard page' do
      get :dashboard
      assert_redirected_to admin_organization_path(@organization.id)
    end
  end

  context 'given a local network contact' do
    setup do
      create_local_network_with_report_recipient
      sign_in @network_contact
    end

    should 'get the dashboard page' do
      get :dashboard
      assert_response :success
      assert_template 'admin/dashboard_network'
    end
  end

  should "show exclusionary criteria when the policy allows it" do
    contact = create(:contact)
    create(:organization, :active_participant, contacts: [contact])
    sign_in contact

    # When we visit the page
    get :dashboard
    assert_response :success

    # We see them
    assert_select "*[role='exclusionary-criteria']"
  end

  test "contacts from delisted organization are no longer allowed to login" do
    contact = create(:contact)
    create(:delisted_participant, contacts: [contact])

    sign_in contact
    get :dashboard

    assert_empty session
    assert_redirected_to new_contact_session_path
  end

  private

  def add_organization_data(organization, user)
    # add some content to the organization
    create(:logo_publication)
    create_cop(organization.id)
    create(:logo_request, :organization_id => organization.id,
      :contact_id      => user.id)
  end

end
