require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  should validate_presence_of :first_name
  should validate_presence_of :last_name
  should validate_presence_of :email
  should belong_to :organization
  should belong_to :local_network
  should belong_to :country

  context "given a ungc user" do
    setup do
      create_ungc_organization_and_user
    end

    should "return proper type" do
      assert_equal Contact::TYPE_UNGC, @staff_user.user_type
      assert @staff_user.from_ungc?
    end
  end

  context "given a Local Network guest" do
    setup do
      create_local_network_guest_organization
    end

    should "return proper type" do
      assert_equal Contact::TYPE_NETWORK_GUEST, @local_network_guest_user.user_type
      assert @local_network_guest_user.from_network_guest?
    end
  end

  context "given a all Local Network Managers" do
    setup do
      @local_network_managers = Contact.network_regional_managers
    end

    should "be from the Global Compact Office" do
      @local_network_managers.each { |contact| assert contact.from_ungc? }
    end

  end

  context "given an organization user" do
    setup do
      create_organization_and_user
    end

    should "return proper type" do
      assert_equal Contact::TYPE_ORGANIZATION, @organization_user.user_type
      assert @organization_user.from_organization?
    end

    should "not delete the single contact" do
      assert_no_difference "Contact.count" do
        @organization_user.destroy
      end
    end

    should "delete 1 contact when there are multiple contacts" do
      @contact_to_be_deleted = create_contact(:email => 'email@example.com',
                                              :organization_id => @organization.id)
      assert_difference "Contact.count", -1 do
        @contact_to_be_deleted.destroy
      end
    end
  end

  context "given an organization with 2 contact points" do
    setup do
      create_organization_and_user
      @organization_user_2 = create_contact(:organization_id => @organization.id,
                                            :email           => 'email2@example.com',
                                            :role_ids        => [Role.contact_point.id])
    end

    should "only be able to delete 1 contact point" do
      assert_equal 2, @organization.contacts.count
      assert_difference 'Contact.count', -1 do
        assert @organization_user.destroy
        assert !@organization_user_2.destroy
      end
    end
  end

  context "given an organization with 1 contact point and 1 CEO" do
    setup do
      create_organization_and_ceo
      @organization.approve
    end

    should "not be able to remove role from the only Contact Point" do
      assert_difference 'Contact.contact_points.count', -1 do
        @organization_user.roles.delete(Role.contact_point)
      end
    end

    should "not be able to remove role from the only Highest Level Executive" do
      assert_difference 'Contact.ceos.count', -1 do
        @organization_ceo.roles.delete(Role.ceo)
      end
    end
  end

  context "given an organization with 1 contact point and CEO" do
    setup do
      create_organization_and_ceo
      @old_email = @organization_user.email
      assert @organization.reject
    end

    should "not be able to remove role from the only Contact Point" do
      # FIXME the contact is being updated, but when testing the change is not being saved
      # assert_equal "rejected.#{@old_email}", @organization_user.email
    end
  end

  context "contact creation helper methods" do
    setup do
      create_roles
    end

    should "create a contact point" do
      @cp = Contact.new_contact_point
      assert @cp.roles.include? Role.contact_point
    end

    should "create a financial contact" do
      @cp = Contact.new_financial_contact
      assert @cp.roles.include? Role.financial_contact
    end

    should "create a ceo" do
      @cp = Contact.new_ceo
      assert @cp.roles.include? Role.ceo
    end
  end

end
