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

      assert_equal 'aaa', @organization_user.reload.username
      assert_equal 'password', @organization_user.reload.plaintext_password

      assert_redirected_to dashboard_path(:tab => :contacts)
    end

    should "destroy contact" do
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

      assert_equal 'aaa', @network_contact.reload.username
      assert_equal 'password', @network_contact.reload.plaintext_password

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

  # TODO: Integrate image tests into test above.
  context 'given a UNGC staff user uploading an image' do
    setup do
      sign_in create_staff_user
      create_local_network_with_report_recipient

      @network_contact_person = create_contact(
        local_network_id: LocalNetwork.last.id,
        role_ids: [Role.network_focal_point.id],
        organization_id: create_organization.id
      )
    end

    context 'given the contact is a UNGC staff user' do
      should 'update image' do
        put :update, id: @staff_user.id, organization_id: @staff_user.organization, contact: @new_contact_attributes.merge({:image => fixture_file_upload('files/untitled.jpg', 'image/jpeg') })
        @staff_user.reload

        assert @staff_user.image.file?
        assert_redirected_to admin_organization_path(@staff_user.organization.id, tab: :contacts)
      end
    end

    context 'given the contact is a contact with the network contact person role' do
      should 'update image' do
        put :update, id: @network_contact_person.id, organization_id: @network_contact_person.organization, contact: @new_contact_attributes.merge({:image => fixture_file_upload('files/untitled.jpg', 'image/jpeg') })
        @network_contact_person.reload

        assert @network_contact_person.image.file?
        assert_redirected_to admin_organization_path(@network_contact_person.organization.id, tab: :contacts)
      end
    end

    context 'given the contact is a not a UNGC staff user or contact with the network contact person role' do
      should 'ignore image and save and redirect' do
        put :update, local_network_id: @local_network.id, id: @network_contact.to_param, contact: {
          :username    => 'aaa',
          :password => 'password'
        }.merge({:image => fixture_file_upload('files/untitled.jpg', 'image/jpeg')})

        assert_redirected_to admin_local_network_path(@local_network.id, tab: :contacts)
      end
    end
  end

  context 'given a contact with the network contact person role uploading an image' do
    setup do
      @network_contact_person = create_contact(
        local_network_id: create_local_network.id,
        role_ids: [Role.network_focal_point.id]
      )

      @another_network_contact_person = create_contact(
        local_network_id: create_local_network.id,
        role_ids: [Role.network_focal_point.id]
      )

      sign_in @network_contact_person
    end

    context 'given the contact is itself' do
      should 'update image' do
        put :update, id: @network_contact_person, local_network_id: @network_contact_person.local_network, contact: @new_contact_attributes.merge({:image => fixture_file_upload('files/untitled.jpg', 'image/jpeg') })
        @network_contact_person.reload

        assert @network_contact_person.image.file?
        assert_redirected_to admin_local_network_path(@network_contact_person.local_network.id, tab: :contacts)
      end
    end

    context 'given the contact is a not itself' do
      should 'ignore image and save and redirect' do
        put :update, id: @another_network_contact_person, local_network_id: @another_network_contact_person.local_network, contact: {
          :username    => 'aaa',
          :password => 'password'
        }.merge({:image => fixture_file_upload('files/untitled.jpg', 'image/jpeg')})

        assert_redirected_to admin_local_network_path(@another_network_contact_person.local_network.id, tab: :contacts)
      end
    end
  end
end
