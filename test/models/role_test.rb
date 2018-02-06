require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :description
  should validate_length_of(:description).is_at_most(255)
  should belong_to :initiative

  def setup_organizations_and_users
    create_organization_and_user
    create_ungc_organization_and_user
    create(:country)
    @non_business_type = create(:organization_type, :name => 'Labour Global', :type_property => 1)
    @business_type = create(:organization_type, :name => 'Company', :type_property => 2)
  end

  test "self.login_roles should be expected" do
    assert_same_elements [
          Role.contact_point,
          Role.network_report_recipient,
          Role.network_focal_point,
          Role.network_executive_director,
          Role.network_board_chair,
          Role.network_guest_user,
          Role.general_contact,
      ], ::Role.login_roles, "Login roles don't match"
  end

  context "given two Roles" do
    setup do
      @role = create(:role, :name => "New Role")
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
      @non_business = create(:organization, :name => 'Labour', :organization_type_id => @non_business_type.id)
      @non_business_contact = create(:contact, :organization_id => @non_business.id,
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
      @business = create(:organization, :name => 'Big Business', :organization_type_id => @business_type.id)
      @business_contact = create(:contact, :organization_id => @business.id,
                                         :email           => 'email2@example.com',
                                         :role_ids        => [Role.contact_point.id])
      @roles = Role.visible_to(@business_contact)
    end

    should "have Financial Contact as a Role option" do
      assert_contains @roles, Role.financial_contact
    end

    context "that has joined the Caring for Climate initiative" do
      setup do
        climate_initiative = Initiative.find_by_filter(:climate)
        @climate_role = create(:role, :name => "Caring for Climate Contact",
          :initiative => climate_initiative)
        climate_initiative.signings.create :signatory => @business
        @roles = Role.visible_to(@business_contact)
      end

      should "have the Caring for Climate role" do
        assert_contains @roles, Role.find_by_name(@climate_role.name)
      end
    end

  end

  context "given a Local Network" do
    setup do
      contact = create(:contact, :network_executive_director)
      local_network = create(:local_network)
      local_network.contacts << contact
      @roles = Role.visible_to(contact)
    end

    should "have focal, report, monthly report and general role options" do
      assert_same_elements [ Role.network_focal_point,
                             Role.network_executive_director,
                             Role.network_board_chair,
                             Role.network_report_recipient,
                             Role.general_contact,
                           ].map(&:name), @roles.pluck(:name)

    end
  end

end
