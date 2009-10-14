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
      assert @staff_user.from_ungc?
    end
  end
  
  context "given an organization user" do
    setup do
      create_organization_user
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
      @contact_to_be_deleted = create_contact(:organization_id => @organization.id)
      assert_difference "Contact.count", -1 do
        @contact_to_be_deleted.destroy
      end
    end
  end
end
