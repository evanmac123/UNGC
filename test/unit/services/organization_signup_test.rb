require 'test_helper'

class OrganizationSignupTest < ActiveSupport::TestCase
  context "has sane defaults" do
    should "have an organization type" do
      create_roles
      @os = BusinessOrganizationSignup.new
      assert_equal @os.business?, true
      assert_equal @os.non_business?, false
    end

    should "have an organization" do
      create_roles
      @os = BusinessOrganizationSignup.new
      assert_equal @os.organization.class, Organization
    end

    should "have a primary_contact" do
      create_roles
      Contact.expects(:new_contact_point).once
      @os = BusinessOrganizationSignup.new
    end

    should "have a ceo" do
      create_roles
      Contact.expects(:new_ceo).once
      @os = BusinessOrganizationSignup.new
    end

    should "have a financial contact" do
      create_roles
      Contact.expects(:new_financial_contact).once
      @os = BusinessOrganizationSignup.new
    end

  end

  context "signup process" do
    setup do
      create_roles
      create_country
      create_country
      @os = BusinessOrganizationSignup.new
    end

    should "set organization attributes" do
      par = {organization: { name: 'foo' }}
      @os.organization.country = Country.last
      @os.set_organization_attributes(par)
      assert_equal @os.organization.name, 'foo'
      assert_equal @os.primary_contact.country, @os.organization.country
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

    should "save non business organization details" do
      create_organization_type(name: 'Academic', type_property: 1 )
      @os = NonBusinessOrganizationSignup.new
      @os.registration.mission_statement = "A"
      @os.organization.expects(:save).once
      @os.primary_contact.expects(:save).once
      @os.ceo.expects(:save).once
      @os.registration.expects(:save).once
      @os.save
    end

  end

  context "validates Business OrganizationSignup" do
    setup do
      create_roles
      create_organization_type(
        name: 'SME',
        type_property: 2,
      )
      @os = BusinessOrganizationSignup.new
    end

    should "not be valid" do
      @os.set_organization_attributes(organization: {name: 'business',
                                                     employees:            50
                                                    }
                                     )
      assert_equal @os.valid?, false
    end

    should "be valid" do
      country = create_country
      sector = create_sector
      listing_status = create_listing_status
      @os.set_organization_attributes(organization: {name: 'business',
                                                     employees:            50,
                                                     country:            country,
                                                     sector:             sector,
                                                     listing_status:     listing_status,
                                                     revenue:     2
                                                    }
                                     )
      assert @os.valid?
    end
  end

  context "validates NonBusinessOrganizationSignup" do
    setup do
      create_roles
      @type = create_organization_type(name: 'Academic', type_property: 1 )
      @country = create_country
      @os = NonBusinessOrganizationSignup.new
    end

    should "validate registration partially" do
      assert !@os.valid_registration?, "should be invalid"
      @os.registration.number = "bla"
      @os.registration.date = "12/3/2013"
      @os.registration.place = "bla"
      @os.registration.authority = "bla"
      assert @os.valid_registration?, "should be valid"
    end

    should "validate registration completely" do
      @os.registration.number = "bla"
      @os.registration.date = "12/3/2013"
      @os.registration.place = "bla"
      @os.registration.authority = "bla"
      assert !@os.complete_valid_registration?, "should be invalid"
      @os.registration.mission_statement = "test"
      assert @os.complete_valid_registration?, "should be valid"
    end

    should "validate organization partially" do
      assert !@os.valid_organization?, "should be invalid"
      @os.set_organization_attributes(organization: {name: 'City University',
                                       employees: 50,
                                       country: @country,
                                       organization_type: @type,
                                       legal_status: fixture_file_upload('files/untitled.pdf', 'application/pdf')})
      assert @os.valid_organization?, "should be valid"

    end

    should "validate organization completely" do
      @os.set_organization_attributes(organization: {:name                 => 'City University',
                                       :employees            => 50,
                                       :legal_status         => fixture_file_upload('files/untitled.pdf', 'application/pdf')})
      assert !@os.complete_valid_organization?, "should be invalid"
      @os.organization.commitment_letter = fixture_file_upload('files/untitled.pdf', 'application/pdf')
      assert @os.complete_valid_organization?, "should be valid"

    end

    should "validate presence of legal status only if registration.number is blank" do
      assert !@os.valid_organization?, "should be invalid"
      @os.set_organization_attributes(organization: {name: 'City University',
                                       country: @country,
                                       organization_type: @type,
                                       employees: 50},
                                      non_business_organization_registration: {number: 10})
      assert @os.valid_organization?, "should be valid"

    end

    should "validate presence of registration.number only if legal status is blank" do
      assert !@os.valid_organization?, "should be invalid"
      @os.set_organization_attributes(organization: {name: 'City University',
                                       country: @country,
                                       organization_type: @type,
                                       legal_status: fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                       employees: 50})
      assert @os.valid_organization?, "should be valid"
    end
  end
end
