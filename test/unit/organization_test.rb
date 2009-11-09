require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
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
      @micro_enterprise = create_organization_type(:name => 'Micro Entreprise')
      @sme = create_organization_type(:name => 'SME')
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
    
    context "setting other pledge amount" do
      setup do
        @organization = Organization.new(:name                 => 'SME',
                                         :employees            => 50,
                                         :pledge_amount        => 500,
                                         :organization_type_id => @companies.id)
      end
      
      should "to 0 should be valid - the pledge amount field should be used" do
        @organization.pledge_amount_other = 0
        assert @organization.save
        assert_equal 500, @organization.pledge_amount
      end
      
      should "to 5,000 should be invalid" do
        @organization.pledge_amount_other = 5000
        assert !@organization.save
        assert @organization.errors.on(:pledge_amount_other)
      end

      should "to 15,000 should be valid" do
        @organization.pledge_amount_other = 15000
        assert @organization.save
        assert_equal 15000, @organization.pledge_amount
      end
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

      @an_org    = create_organization
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
end
