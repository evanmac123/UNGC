require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  should_validate_presence_of :first_name, :last_name
  should_belong_to :organization
  should_belong_to :country
  
  context "given a ungc user" do
    setup do
      create_ungc_organization
    end
    
    should "return proper type" do
      assert_equal Contact::TYPE_UNGC, @staff_user.user_type
      assert @organization_user.from_ungc?
    end
  end
  
  context "given a ungc user" do
    setup do
      create_organization_user
    end
    
    should "return proper type" do
      assert_equal Contact::TYPE_ORGANIZATION, @organization_user.user_type
      assert @organization_user.from_organization?
    end
  end

  context "given a contact point" do
    setup do
      create_organization_user
    end
    
    should "not be the last to be deleted" do
      @organization_user.destroy
      assert_equal 1, @organization_user.organization.contacts.length
    end
  end
  
end
