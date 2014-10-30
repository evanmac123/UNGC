require 'test_helper'

class Admin::ContactsControllerTest < ActionController::TestCase

  def setup
    create_organization_type
    create_country
    create_roles
    create_organization_and_ceo

    @new_contact_attributes = {
      :first_name => 'Dude',
      :last_name  => 'Smith',
      :prefix     => 'Mr',
      :job_title  => 'Job Title',
      :phone      => '+1 416 1234567',
      :address    => '123 Example Ave',
      :city       => 'Toronto',
      :country_id => Country.first.id,
      :email      => 'test@example.com',
      :username   => 'test',
      :password   => 'test'
    }
  end

  context "when logged in as an organization user" do
    setup do
      sign_in @organization_user
    end

    should "display the 'new contact' form" do
      @organization.update_attribute(:country_id, Country.first.id)
      get :new, :organization_id => @organization.id
      assert_response :success
      assert_select "form[action=#{admin_organization_contacts_path(@organization.id).inspect}]"
      assert_select "option[value=#{@organization.country_id.inspect}][selected='selected']"
    end

    should "be only able to assign contact and financial roles when editing a contact" do
      get :edit, :organization_id => @organization.id,
                 :id => @organization_user.to_param

      assert_response :success
      assert_same_elements [ Role.contact_point, Role.financial_contact], assigns(:roles)
    end

    should "create contact" do
      assert_difference('@organization.contacts.count') do
        post :create, :organization_id => @organization.id, :contact => @new_contact_attributes
      end

      assert_redirected_to dashboard_path(:tab => :contacts)
    end

    should "get the 'edit contact' form for an organization" do
      get :edit, :organization_id => @organization.id,
                 :id => @organization_user.to_param

      assert_response :success
      assert_select "form[action=#{admin_organization_contact_path(@organization.id, @organization_user.id).inspect}]"
    end

    should "update contact for an organization" do
      put :update, :organization_id => @organization.id,
                   :id              => @organization_user.to_param,
                   :contact         => { :username    => 'aaa',
                                         :password => "password" }

      @organization_user.reload
      assert_equal 'aaa', @organization_user.username
      assert @organization_user.valid_password? 'password'

      assert_redirected_to dashboard_path(:tab => :contacts)
    end

    should "destroy contact" do
      @organization.update(participant: true)
      @contact_to_be_deleted = create_contact(:organization_id => @organization.id,
                                              :email           => "dude2@example.com")
      assert_difference('Contact.count', -1) do
        delete :destroy, :organization_id => @organization.id,
                         :id => @contact_to_be_deleted.to_param
      end
      assert_redirected_to dashboard_path(:tab => :contacts)
    end
  end

  context "when logged in as UNGC staff user" do
    setup do
      create_local_network_with_report_recipient
      sign_in create_staff_user
    end

    should "be able to assign the three organization roles when editing a contact" do
      get :edit, :organization_id => @organization.id,
                 :id => @organization_user.to_param

      assert_response :success
      assert_same_elements [ Role.contact_point,
                             Role.financial_contact,
                             Role.survey_contact,
                             Role.ceo], assigns(:roles)
    end

    should "display the 'new contact' form for a local network" do
      get :new, :local_network_id => @local_network.id
      assert_response :success
      assert_select "form[action=#{admin_local_network_contacts_path(@local_network.id).inspect}]"
    end

    should "create contact for a local network" do
      assert_difference('@local_network.contacts.count') do
        post :create, :local_network_id => @local_network.id, :contact => @new_contact_attributes
      end

      assert_redirected_to admin_local_network_path(@local_network.id, :tab => :contacts)
    end

    should "get the 'edit contact' form for a local network" do
      get :edit, :local_network_id => @local_network.id,
                 :id => @network_contact.to_param

      assert_response :success
      assert_select "form[action=#{admin_local_network_contact_path(@local_network.id, @network_contact.id).inspect}]"
    end

    should "update contact for a local network" do
      put :update, :local_network_id => @local_network.id,
                   :id               => @network_contact.to_param,
                   :contact          => { :username    => 'aaa',
                                          :password => "password" }

      @network_contact.reload
      assert_equal 'aaa', @network_contact.username
      assert @network_contact.valid_password? 'password'

      assert_redirected_to admin_local_network_path(@local_network.id, :tab => :contacts)
    end

    should "destroy contact for a local network" do
      @contact_to_be_deleted = create_contact(:local_network_id => @local_network.id,
                                              :organization_id  => nil,
                                              :email           => "dude2@example.com")

      assert_difference('Contact.count', -1) do
        delete :destroy, :local_network_id => @local_network.id,
                         :id => @contact_to_be_deleted.to_param
      end

      assert_redirected_to admin_local_network_path(@local_network.id, :tab => :contacts)
    end

    should "redirect to the organization's path after updating its contact" do
      put :update, :organization_id => @organization.id,
                   :id              => @organization_user.to_param,
                   :contact         => { :username    => 'aaa',
                                         :password => "password" }

      assert_redirected_to admin_organization_path(@organization.id, :tab => :contacts)
    end

    should "get the search page" do
      get :search
      assert_response :success
      assert_template 'search'
    end
  end

  context "when logged in as a Local Network" do
    setup do
      create_local_network_with_report_recipient
       sign_in @network_contact
    end

    should "redirect to dashboard contacts tab" do
      put :update, :local_network_id => @local_network.id, :id => @network_contact.to_param
      assert_redirected_to admin_local_network_path(@local_network.id, :tab => :contacts)
    end
  end

  context "signing in a contact point" do

    should 'be allowed for Network Report Recipients of the same network' do
      contact       = create_contact_role Role.network_report_recipient
      contact_point = create_contact_role Role.contact_point

      sign_in contact
      post :sign_in_as, id: contact_point

      assert_nil flash[:notice]
      assert_redirected_to dashboard_url
    end

    should 'not be allowed for Network Report Recipients from another network' do
      country = create_country(local_network: create_local_network)
      org_in_other_network = create_organization(country: country)
      contact                      = create_contact_role Role.network_report_recipient
      contact_point_from_other_org = create_contact_role Role.contact_point, org_in_other_network

      sign_in contact
      post :sign_in_as, id: contact_point_from_other_org

      assert_equal 'Unauthorized', flash[:notice]
      assert_redirected_to dashboard_url(tab: 'sign_in_as_contact_point')
    end

    should 'not sign in roles other than contact point' do
      contact = create_contact_role Role.network_report_recipient
      ceo     = create_contact_role Role.ceo

      sign_in contact
      post :sign_in_as, id: ceo

      assert_equal 'Unauthorized', flash[:notice]
      assert_redirected_to dashboard_url(tab: 'sign_in_as_contact_point')
    end

    def create_contact_role(role, organization = nil)
      organization ||= @organization
      create_contact \
        organization: organization,
        roles: [role],
        local_network: organization.local_network
    end

  end
end
