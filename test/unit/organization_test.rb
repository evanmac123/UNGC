require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  # FIXME create object first
  # should_validate_uniqueness_of :name
  should_validate_presence_of :name
  should_have_many :contacts
  should_have_many :logo_requests
  should_have_many :case_stories
  should_have_many :communication_on_progresses
  should_have_many :comments
  should_belong_to :sector
  should_belong_to :organization_type
  should_belong_to :listing_status
  should_belong_to :exchange
  should_belong_to :country
  
  context "given a new organization" do
    setup do
      @companies = create_organization_type(:name => 'Company')
      @micro_enterprise = create_organization_type(:name => 'Micro Enterprise')
      @sme = create_organization_type(:name => 'SME')
      @academic = create_organization_type(:name => 'Academic')
    end
    
    should "set the organization type to micro enterprise when it has less than 10 employees" do
      @organization = Organization.create(:name                 => 'Small Company',
                                          :employees            => 2,
                                          :organization_type_id => @companies.id)
      assert_equal @micro_enterprise.id, @organization.organization_type_id
      assert @organization.micro_enterprise?
    end
    
    should "set the organization type to SME when it has between 10 and 250 employees" do
      @organization = Organization.create(:name                 => 'SME',
                                          :employees            => 50,
                                          :organization_type_id => @companies.id)
      assert_equal @sme.id, @organization.organization_type_id
    end
    
    should "set the organization type to Company when it has more than 250 employees" do
      @organization = Organization.create(:name                 => 'SME should be a Company',
                                          :employees            => 500,
                                          :organization_type_id => @sme.id)
      assert_equal @companies.id, @organization.organization_type_id
    end
    
    should "set sector to 'not applicable' when it is a non-business" do
      @non_business = create_organization_type(:name => 'Foundation', :type_property => 1)
      @sector = create_sector(:name => "Media")
      @sector_not_applicable = create_sector(:name => "Not Applicable")
      @organization = Organization.create(:name => "Foundation",
                                          :employees => 5,
                                          :organization_type_id => @non_business.id,
                                          :sector => @sector )
      assert_equal @sector_not_applicable, @organization.sector
    end
    
    should "identify Academic organizations" do
      @organization = Organization.create(:name => "University",
                                          :employees => 5,
                                          :organization_type_id => @academic.id)
      assert @organization.academic?
    end
        
    context "approving its participation" do
      setup do
        @organization = Organization.create(:name => 'Company', :employees => 100)
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
        @financial = create_contact(:organization_id => @organization.id,
                                              :email           => 'email2@example.com',
                                              :role_ids        => [Role.financial_contact.id])
        assert_equal @organization.contacts.contact_points.first, @organization_user
        assert_equal @organization.contacts.financial_contacts.first,  @financial
        @organization.contacts.financial_contacts.first.destroy
        assert_equal @organization.contacts.financial_contacts.count,  0
        assert_equal @organization.financial_contact_or_contact_point, @organization_user
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
      
      should "rename organization" do
        name = @organization.name
        @organization.reject
        @organization.reload
        assert !@organization.participant
        assert_equal "#{name} (rejected)", @organization.name
      end

      should "rename organization" do
        name = @organization.name
        @organization.reject_micro
        @organization.reload
        assert !@organization.participant
        assert_equal "#{name} (rejected)", @organization.name
      end
     
   end
  
  
  context "given a climate change initiative, some organization types and an org" do
    setup do
      @academia  = create_organization_type(:name => 'Academic')
      @public    = create_organization_type(:name => 'Public Sector Organization')
      @companies = create_organization_type(:name => 'Company')
      @sme       = create_organization_type(:name => 'SME')
      @micro     = create_organization_type(:name => 'Micro Entreprise')
      @climate   = create_initiative(:id => 2, :name => 'Climate Change')

      @an_org    = create_organization(:organization_type_id => @sme.id, :employees => 50)
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
        @an_org.update_attribute :organization_type, @sme
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
         @organization.update_attribute :commitment_letter, fixture_file_upload('files/untitled.pdf', 'application/pdf')
        end
       
        should "be able to submit a COP" do
         assert @organization.can_submit_cop?
        end
      end
      
      context "and they are Non-Communicating" do
        setup do
         @organization.update_attribute :cop_state, Organization::COP_STATE_NONCOMMUNICATING
        end
       
        should "be able to submit a COP" do
         assert @organization.can_submit_cop?
        end
      end
      
     
     end
  
end
