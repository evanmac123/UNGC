require 'test_helper'

class OrganizationSignupTest < ActiveSupport::TestCase
  context "has sane defaults" do
    should "have an organization type" do
      @os = BusinessOrganizationSignup.new
      assert_equal @os.business?, true
      assert_equal @os.non_business?, false
    end

    should "have an organization" do
      @os = BusinessOrganizationSignup.new
      assert_equal @os.organization.class, Organization
    end

    should "have a primary_contact" do
      Contact.expects(:new_contact_point).once
      @os = BusinessOrganizationSignup.new
    end

    should "have a ceo" do
      Contact.expects(:new_ceo).once
      @os = BusinessOrganizationSignup.new
    end

    should "have a financial contact" do
      Contact.expects(:new_financial_contact).once
      @os = BusinessOrganizationSignup.new
    end

  end

  context "signup process" do
    setup do
      create(:country)
      create(:country)
      @os = BusinessOrganizationSignup.new
      @os.set_organization_attributes(attributes_for(:organization))
      @os.set_primary_contact_attributes(new_contact_attributes)
    end

    should "set organization attributes" do
      par = {name: 'foo'}
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
      @os.set_primary_contact_attributes(new_contact_attributes)
      @os.set_ceo_attributes(new_contact_attributes)
      @os.organization.expects(:save!).once
      @os.primary_contact.expects(:save!).once
      @os.ceo.expects(:save!).once
      @os.save
    end

    should "persist organization, contacts and the financial contact" do
      @os.set_primary_contact_attributes(new_contact_attributes)
      @os.set_ceo_attributes(new_contact_attributes)
      @os.organization.pledge_amount = 1000

      @os.organization.expects(:save!).once
      @os.primary_contact.expects(:save!).once
      @os.ceo.expects(:save!).once
      @os.financial_contact.expects(:save).once
      @os.save
    end

    should "save non business organization details" do
      create(:organization_type, name: 'Academic', type_property: 1)
      @os = NonBusinessOrganizationSignup.new
      @os.set_organization_attributes(attributes_for(:organization))
      @os.set_primary_contact_attributes(new_contact_attributes)
      @os.set_ceo_attributes(new_contact_attributes)
      @os.set_registration_attributes(attributes_for(:non_business_organization_registration))

      @os.organization.expects(:save!).once
      @os.primary_contact.expects(:save!).once
      @os.ceo.expects(:save!).once
      @os.registration.expects(:save!).once
      @os.save
    end

  end

  context "validates Business OrganizationSignup" do
    setup do
      create(:organization_type,
        name: 'SME',
        type_property: 2,
      )
      @os = BusinessOrganizationSignup.new
    end

    should "not be valid" do
      @os.set_organization_attributes({name: 'business',
                                                     employees:            50
                                                    }
                                     )
      assert_equal @os.valid?, false
    end

    should "be valid" do
      country = create(:country)
      sector = create(:sector)
      listing_status = create(:listing_status)
      @os.set_organization_attributes({name: 'business',
                                                     employees:            50,
                                                     country:            country,
                                                     sector:             sector,
                                                     listing_status:     listing_status,
                                                     revenue:     2
                                                    }
                                     )
      assert @os.valid?
    end

    should "validate presence of pledge or no pledge reason" do
      @os.set_organization_attributes({pledge_amount: 0})
      refute @os.organization.errors.any?
      refute @os.pledge_complete?
      @os.set_organization_attributes({no_pledge_reason: ""})
      refute @os.pledge_complete?
      assert @os.organization.errors.any?
      @os.set_organization_attributes({no_pledge_reason: "no pledge"})
      assert @os.pledge_complete?
      refute @os.organization.errors.any?
    end

    should "assign default for pledge amount" do
      assert @os.organization.pledge_amount.blank?
      @os.set_organization_attributes({revenue: 2})
      refute @os.organization.pledge_amount.blank?
    end
  end

  context "validates NonBusinessOrganizationSignup" do
    setup do
      @type = create(:organization_type, name: 'Academic', type_property: 1 )
      @country = create(:country)
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
      @os.set_organization_attributes({name: 'City University',
                                       employees: 50,
                                       country: @country,
                                       organization_type: @type,
                                       legal_status: fixture_file_upload('files/untitled.pdf', 'application/pdf')})
      assert @os.valid_organization?, "should be valid"

    end

    should "validate organization completely" do
      @os.set_organization_attributes({:name                 => 'City University',
                                       :employees            => 50,
                                       :legal_status         => fixture_file_upload('files/untitled.pdf', 'application/pdf')})
      assert !@os.complete_valid_organization?, "should be invalid"
      @os.organization.commitment_letter = fixture_file_upload('files/untitled.pdf', 'application/pdf')
      assert @os.complete_valid_organization?, "should be valid"

    end

    should "validate presence of legal status only if registration.number is blank" do
      assert !@os.valid_organization?, "should be invalid"
      @os.set_organization_attributes({name: 'City University',
                                       country: @country,
                                       organization_type: @type,
                                       employees: 50})
      @os.set_registration_attributes(number: 10)
      assert @os.valid_organization?, "should be valid"

    end

    should "validate presence of registration.number only if legal status is blank" do
      assert !@os.valid_organization?, "should be invalid"
      @os.set_organization_attributes({name: 'City University',
                                       country: @country,
                                       organization_type: @type,
                                       legal_status: fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                       employees: 50})
      assert @os.valid_organization?, "should be valid"
    end
  end

  private

  def new_contact_attributes
    attributes_for(:contact).merge(
      password: Faker::Internet.password
    )
  end

end
