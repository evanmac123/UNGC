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

  context "signup process" do
    setup do
      @os = OrganizationSignup.new('business')
    end

    should "set organization attributes" do
      par = { name: 'foo' }
      @os.set_organization_attributes(par)
      assert_equal @os.organization.name, 'foo'
    end

    should "set primary contact" do
      create_roles
      par = { first_name: 'foo' }
      @os.set_primary_contact_attributes_and_prepare_ceo(par)
      assert_equal @os.primary_contact.first_name, 'foo'
    end

    should "clone primary contact to ceo" do
      create_roles
      par = { phone: '3442342344' }
      @os.set_primary_contact_attributes_and_prepare_ceo(par)
      assert_equal @os.ceo.phone, '3442342344'
    end
  end
end
