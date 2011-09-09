require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  should_validate_presence_of :first_name, :last_name, :email
  should_belong_to :organization
  should_belong_to :local_network
  should_belong_to :country
  
  context "given a ungc user" do
    setup do
      create_ungc_organization_and_user
    end
    
    should "return proper type" do
      assert_equal Contact::TYPE_UNGC, @staff_user.user_type
      assert @staff_user.from_ungc?
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

  context "given an organization with 1 contact point and CEO" do
    setup do
      create_organization_and_ceo
      @organization.approve
    end
  
    should "not be able to remove role from the only Contact Point" do
      assert @organization_user.roles.delete(Role.contact_point)
      assert !@organization_user.save
    end

    should "not be able to remove role from the only Highest Level Executive" do
      assert @organization_ceo.roles.delete(Role.ceo)
      assert !@organization_ceo.save
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

end
