require 'test_helper'

class OrganizationSignupTest < ActiveSupport::TestCase
  context "has sane defaults" do
    setup do
      @os = OrganizationSignup.new('business')
    end

    should "have an organization type" do
      assert_equal @os.business?, true
      assert_equal @os.non_business?, false
    end

    should "have an organization" do
      assert_equal @os.organization.class, Organization
    end

    should "have a primary_contact" do
      Contact.expects(:new_contact_point).once
      @os.primary_contact
    end

    should "have a ceo" do
      Contact.expects(:new_ceo).once
      @os.ceo
    end

    should "have a financial contact" do
      Contact.expects(:new_financial_contact).once
      @os.financial_contact
    end

  end
end
