require 'test_helper'

class OrganizationSignupTest < ActiveSupport::TestCase
  context "has sane defaults" do
    should "have an organization type" do
      create_roles
      @os = OrganizationSignup.new('business')
      assert_equal @os.business?, true
      assert_equal @os.non_business?, false
    end

    should "have an organization" do
      create_roles
      @os = OrganizationSignup.new('business')
      assert_equal @os.organization.class, Organization
    end

    should "have a primary_contact" do
      create_roles
      Contact.expects(:new_contact_point).once
      @os = OrganizationSignup.new('business')
    end

    should "have a ceo" do
      create_roles
      Contact.expects(:new_ceo).once
      @os = OrganizationSignup.new('business')
    end

    should "have a financial contact" do
      create_roles
      Contact.expects(:new_financial_contact).once
      @os = OrganizationSignup.new('business')
    end

  end

  context "signup process" do
    setup do
      create_roles
      @os = OrganizationSignup.new('business')
    end

    should "set organization attributes" do
      par = { name: 'foo' }
      @os.set_organization_attributes(par)
      assert_equal @os.organization.name, 'foo'
    end

    should "set primary contact" do
      par = { first_name: 'foo' }
      @os.set_primary_contact_attributes(par)
      assert_equal @os.primary_contact.first_name, 'foo'
    end

    should "clone primary contact to ceo" do
      par = { phone: '3442342344' }
      @os.set_primary_contact_attributes(par)
      @os.prepare_ceo
      assert_equal @os.ceo.phone, '3442342344'
    end

    should "set ceo" do
      par = { first_name: 'foo' }
      @os.set_ceo_attributes(par)
      assert_equal @os.ceo.first_name, 'foo'
    end

    should "clone primary contact to financial contact" do
      par = { city: 'nowheresville' }
      @os.set_primary_contact_attributes(par)
      @os.prepare_financial_contact
      assert_equal @os.financial_contact.city, 'nowheresville'
    end

    should "set financial contact attributes" do
      par = { city: 'nowheresville' }
      @os.set_financial_contact_attributes(par)
      assert_equal @os.financial_contact.city, 'nowheresville'
    end

    should "set primary contact as financial contact" do
      par = { foundation_contact: 1 }
      @os.set_financial_contact_attributes(par)
      assert @os.primary_contact.is? Role.financial_contact
    end

    should "persist the organization and the contacts" do
      @os.organization.expects(:save).once
      @os.primary_contact.expects(:save).once
      @os.ceo.expects(:save).once
      @os.save
    end

    should "persist organization, contacts and the financial contact" do
      @os.organization.pledge_amount = 1000
      @os.organization.expects(:save).once
      @os.primary_contact.expects(:save).once
      @os.ceo.expects(:save).once
      @os.financial_contact.expects(:save).once
      @os.save
    end

  end
end
