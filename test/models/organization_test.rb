require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  # FIXME create object first
  # should validate_uniqueness_of :name
  should validate_presence_of :name
  should have_many :contacts
  should have_many :logo_requests
  should have_many :communication_on_progresses
  should have_many :comments
  should belong_to :sector
  should belong_to :organization_type
  should belong_to :listing_status
  should belong_to :exchange
  should belong_to :country
  should have_one  :non_business_organization_registration
  should have_one  :legal_status
  should have_one  :recommitment_letter
  should have_one  :withdrawal_letter

  context "given an existing organization with a contact and ceo" do
    setup do
      create_organization_and_ceo
    end
    should "delete both contacts when deleting organization" do
       assert_difference "Contact.count", -2 do
         @organization.destroy
        end
    end
  end

  context "given a new organization" do

    should "set the organization type to SME when it has less than 10 employees" do
      @organization = Organization.create(:name                 => 'Approved small Company',
                                          :employees            => 2,
                                          :organization_type    => OrganizationType.company,
                                          :state                => ApprovalWorkflow::STATE_APPROVED)
      assert_equal OrganizationType.sme, @organization.organization_type
      assert !@organization.micro_enterprise?
    end

    should "set the organization type to Micro Enterprise when it has less than 10 employees
            unless the organization is approved" do
      @organization = Organization.create(:name                 => 'Small Company',
                                          :employees            => 2,
                                          :organization_type    => OrganizationType.company,
                                          :state                => ApprovalWorkflow::STATE_PENDING_REVIEW)
      assert @organization.micro_enterprise?

    end

    should "set the organization type to SME when it has between 10 and 250 employees" do
      @organization = Organization.create(:name                 => 'SME',
                                          :employees            => 50,
                                          :organization_type    => OrganizationType.company)
      assert_equal OrganizationType.sme, @organization.organization_type
    end

    should "set the organization type to Company when it has more than 250 employees" do
      @organization = Organization.create(:name                 => 'SME should be a Company',
                                          :employees            => 500,
                                          :organization_type    => OrganizationType.sme)
      assert_equal OrganizationType.company, @organization.organization_type
    end

    should "set sector and listing_status to 'not applicable' when it is a non-business" do
      @listing_status = create(:listing_status, :name => "Private Company")
      @listing_not_applicable = create(:listing_status, :name => "Not Applicable")
      @organization = Organization.create(:name => "Foundation",
                                          :employees => 5,
                                          :organization_type => OrganizationType.foundation,
                                          :sector => @sector,
                                          :listing_status => @listing_status)
      assert_equal Sector.not_applicable, @organization.sector
      assert_equal @listing_not_applicable, @organization.listing_status
    end

    context "that is a non-business participant" do
      setup do
        @organization = Organization.create(:name => "University",
                                            :employees => 5,
                                            :organization_type => OrganizationType.academic)
        @organization.approve
      end

      should "assign initial cop_due_on two years later" do
        assert_equal 2.year.from_now.to_date, @organization.cop_due_on.to_date
      end
    end

    should "set sector when it is a signatory" do
      media_sector = Sector.find_by(name: 'Media')
      @organization = Organization.create(:name => "Signatory",
                                          :employees => 10,
                                          :organization_type => OrganizationType.signatory,
                                          :sector => media_sector)
      assert_equal media_sector, @organization.sector
    end

    should "identify Academic organizations" do
      @organization = Organization.create(:name => "University",
                                          :employees => 5,
                                          :organization_type => OrganizationType.academic)
      assert @organization.academic?
    end

    context "approving its participation" do
      setup do
        @organization = Organization.create(:name => 'Company',
                                            :employees => 100,
                                            :organization_type => OrganizationType.company)
      end

      should "update approval related fields" do
        assert_nil @organization.cop_due_on
        @organization.approve
        @organization.reload
        # set the COP due date to 1 year
        assert_equal 1.year.from_now.to_date, @organization.cop_due_on
        # set the paticipant flag to true
        assert @organization.participant
        # set the join date today
        assert_equal Date.today, @organization.joined_on
      end

      should "find a financial contact or default to a contact point" do
        create_organization_and_user
        @financial = create(:contact, :organization_id => @organization.id,
                                    :email           => 'email2@example.com',
                                    :role_ids        => [Role.financial_contact.id])

        assert_equal @organization.contacts.contact_points.first, @organization_user
        assert_equal @organization.contacts.financial_contacts.first, @financial
        assert @organization.financial_contact_and_contact_point.include?(@organization_user)
        assert @organization.financial_contact_and_contact_point.include?(@financial)

        @organization.contacts.financial_contacts.first.destroy
        assert_equal @organization.contacts.financial_contacts.count,  0
        assert_equal @organization.financial_contact_or_contact_point, @organization_user
      end

      should "reset review reason after changing state to network review" do
        @organization.update_attribute :review_reason, 'organization_type'
        @organization.network_review
        assert_nil @organization.review_reason
      end

      should "reverse contact and ceo roles if the information was incorrectly entered in the signup registration form" do
        create_organization_and_ceo
        assert @organization.reverse_roles
      end

      should "reverse roles only if there is one contact and one ceo" do
        # only create a contact point - there is no CEO
        create_organization_and_user
        assert !@organization.reverse_roles
      end

    end
  end

   context "rejecting its participation" do
      setup do
        create_organization_and_ceo
      end

      should "set rejection date" do
        @organization.reject
        assert_equal Date.today, @organization.rejected_on
      end

   end

  context "given a climate change initiative, some organization types and an org" do
    setup do
      @climate   = create(:initiative, :id => 2, :name => 'Climate Change')

      @an_org    = create(:organization, :organization_type => OrganizationType.sme, :employees => 50)
    end

    should "find no orgs when filtering by initiative for climate" do
      assert_equal [], Organization.for_initiative(:climate)
    end

    context "and an_org joins the climate initiative" do
      setup do
        @climate.signings.create :signatory => @an_org
      end

      should "find cc_org when filtering by initiative for climate" do
        assert_same_elements [@an_org], Organization.for_initiative(:climate)
      end
    end

    context "and an_org is an SME" do
      setup do
        @an_org.update_attribute :organization_type, OrganizationType.sme
      end

      should "find an_org when filtering by type" do
        assert_same_elements [@an_org], Organization.by_type(:sme)
      end

      context "and THEN signs the climate change initiative" do
        setup do
          @climate.signings.create :signatory => @an_org
        end

        should "find an_org when filtering by_type for_initiative" do
          assert_same_elements [@an_org], Organization.by_type(:sme).for_initiative(:climate)
        end
      end
    end
  end

  context "given an expelled company" do
    setup do
      create_expelled_organization
    end

    should "not be able to submit a COP" do
      assert !@organization.can_submit_cop?
    end

    context "and a staff member updates their Letter of Commitment" do
      setup do
        @organization.recommitment_letter_file = fixture_file_upload('files/untitled.pdf', 'application/pdf')
        @organization.save
      end

      should "be able to submit a COP" do
        assert @organization.can_submit_cop?
      end
    end
  end

  should 'be able to submit after withdrawing and submitting a letter of recommitment' do
    # Given a withdrawn organization
    create_expelled_organization
    @organization.update!(removal_reason: RemovalReason.withdrew)
    assert_not @organization.can_submit_cop?

    # When they submit a recommitment letter
    @organization.update!(recommitment_letter_file: fixture_file_upload('files/untitled.pdf', 'application/pdf'))

    # Then they should be able to submit a COP again
    assert @organization.can_submit_cop?
  end

  context "given a Non-Communicating participant" do
    setup do
      create_organization_and_user
      @organization.update_attribute :cop_state, Organization::COP_STATE_NONCOMMUNICATING
    end

    context "#delisting_on" do

      should "have a predicted delisting date one year after their COP due date" do
        business = create(:business, cop_due_on: Date.new(2015, 10, 31))
        assert_equal Date.new(2016, 10, 31), business.delisting_on
      end

      should "have a predicted delisting date one year after a non business' COE due date" do
        non_business = create(:non_business, cop_due_on: Date.new(2015, 10, 31))
        assert_equal Date.new(2016, 10, 31), non_business.delisting_on
      end

      should "return nil for already delisted organizations" do
        business = create(:business, cop_state: 'delisted')
        assert_nil business.delisting_on
      end

      should "return nil when there is no cop_due_on yet" do
        business = create(:business, cop_due_on: nil)
        assert_nil business.cop_due_on
        assert_nil business.delisting_on
      end
    end

    should "be able to submit a COP" do
      assert @organization.can_submit_cop?
    end

  end

  context "given an organization" do
    setup do
      create_organization_and_user
    end

    should "return expected attributes with to_json" do
      json = @organization.to_json
      result = JSON.parse(json)
      assert_equal ['id', 'name','sector_name', 'country_name', 'participant'].sort, result.keys.sort
    end

    should "return expected attributes with to_json with only option" do
      json = @organization.to_json(:only => ['stock_symbol'])
      result = JSON.parse(json)
      assert_equal ['id', 'name','sector_name', 'country_name', 'participant', 'stock_symbol'].sort, result.keys.sort
    end

    should "properly interpret extras options as either only or method" do
      json = @organization.to_json(:extras => ['stock_symbol', 'local_network_country_code'])
      result = JSON.parse(json)
      assert_equal ['id', 'name','sector_name', 'country_name', 'local_network_country_code', 'participant', 'stock_symbol'].sort, result.keys.sort
    end
  end

  context "given a new organization from Brazil" do
    setup do
      @country = create(:country, :name => "Brazil" )
      @participant_manager = create_participant_manager
      @country = create(:country, :participant_manager => @participant_manager)
      @organization = create(:organization, :organization_type => OrganizationType.company, :country_id => @country.id)
    end
    should "assign the Relationship Manager for Brazil" do
      assert_equal @participant_manager, @organization.participant_manager
    end
  end

  context "uniqueness of name" do

    context "in the application layer" do

      should "not allow exact duplicates" do
        create(:organization, name: "simple")
        org = build(:organization, name: "simple")

        refute org.valid?
        assert_contains org.errors.messages[:name], "has already been used by another organization"
      end

      should "not allow two names that are the same, differing only by accents" do
        create(:organization, name: "Fundación")
        org = build(:organization, name: "Fundacion")

        refute org.valid?
        assert_contains org.errors.messages[:name], "has already been used by another organization"
      end

      should "not allow two names that are the same, differing only by case" do
        create(:organization, name: "Fundación")
        org = build(:organization, name: "FUNDACION")

        refute org.valid?
        assert_contains org.errors.messages[:name], "has already been used by another organization"
      end

    end

    context "in the database layer" do

      should "not allow exact duplicates" do
        create(:organization, name: "simple")
        org = build(:organization, name: "simple")

        assert_raise ActiveRecord::RecordNotUnique do
          org.save!(validate: false)
        end
      end

      should "not allow two names that are the same, differing only by accents" do
        create(:organization, name: "Fundación")
        org = build(:organization, name: "Fundacion")

        assert_raise ActiveRecord::RecordNotUnique do
          org.save!(validate: false)
        end
      end

      should "not allow two names that are the same, differing only by case" do
        create(:organization, name: "Fundación")
        org = build(:organization, name: "FUNDACION")

        assert_raise ActiveRecord::RecordNotUnique do
          org.save!(validate: false)
        end
      end

    end

  end

  test "scope publicly visible delisted organizations" do
    # Given removed organizations for each reason
    RemovalReason.all.map do |reason|
      create(:delisted_participant, removal_reason: reason)
    end

    # we should only get delisted and withdrawn/requested organizations back
    actual = Organization.joins(:removal_reason)
      .publicly_delisted
      .pluck("removal_reasons.description")

    expected = [
      RemovalReason::FILTERS[:delisted],
      RemovalReason::FILTERS[:requested],
    ]

    assert_equal expected.sort, actual.sort
  end

end
