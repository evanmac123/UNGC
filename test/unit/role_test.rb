require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  should_validate_presence_of :name, :description
  should_belong_to :initiative

  def setup_organizations_and_users
    create_organization_and_user
    create_ungc_organization_and_user
    create_country
    @non_business_type = create_organization_type(:name => 'Labour Global', :type_property => 1)
    @business_type = create_organization_type(:name => 'Company', :type_property => 2)
  end

  context "given two Roles" do
    setup do
      create_roles
      @role = create_role(:name => "New Role")
      @defined_role = Role.website_editor
    end

    should "can change the new Role name" do
      @role.name = "Changed Role"
      assert @role.save
    end

    should "cannot change the defined Role name" do
      @defined_role.name = "Changed Role"
      assert !@defined_role.save
    end
  end

  context "given a non-business organization" do
    setup do
      setup_organizations_and_users
      @non_business = create_organization(:name => 'Labour', :organization_type_id => @non_business_type.id)
      @non_business_contact = create_contact(:organization_id => @non_business.id,
                                             :email           => 'email2@example.com',
                                             :role_ids        => [Role.contact_point.id])
      @roles = Role.visible_to(@non_business_contact)
    end

    should "not have Financial Contact as a Role option" do
      assert_does_not_contain @roles, Role.financial_contact
    end

    should "have CEO and Contact Point role options" do
      assert_same_elements [Role.ceo, Role.contact_point], @roles
    end
  end

  context "given a business organization" do
    setup do
      setup_organizations_and_users
      @business = create_organization(:name => 'Big Business', :organization_type_id => @business_type.id)
      @business_contact = create_contact(:organization_id => @business.id,
                                         :email           => 'email2@example.com',
                                         :role_ids        => [Role.contact_point.id])
      @roles = Role.visible_to(@business_contact)
    end

    should "have Financial Contact as a Role option" do
      assert_contains @roles, Role.financial_contact
    end

    context "that has joined the Caring for Climate initiative" do
      setup do
        create_initiatives
        @climate_role = create_role(:name => "Caring for Climate Contact", :initiative_id => @climate_initiative.id)
        @climate_initiative.signings.create :signatory => @business
        @roles = Role.visible_to(@business_contact)
      end

      should "have the Caring for Climate role" do
        assert_contains @roles, Role.find_by_name(@climate_role.name)
      end
    end

  end

  context "given a Local Network" do
    setup do
      create_local_network_with_report_recipient
      @roles = Role.visible_to(@network_contact)
    end

    should "have focal, rep, report, monthly report and general role options" do
      assert_same_elements [ Role.network_focal_point,
                             Role.network_representative,
                             Role.network_report_recipient,
                             Role.general_contact ], @roles

    end
  end

end
