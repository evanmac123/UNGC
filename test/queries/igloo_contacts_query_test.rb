require 'test_helper'

class IglooContactsQueryTest < ActiveSupport::TestCase

  test "include a contact updated recently" do
    travel_to 2.year.ago
    updated = create_ap_subcriber
    not_updated = create_ap_subcriber

    travel_back
    updated.touch

    results = IglooContactsQuery.new.run
    assert_includes results, updated
    assert_not_includes results, not_updated
  end

  test "include contact if organization has been updated recently" do
    travel_to 2.years.ago
    updated = create_ap_subcriber
    not_updated = create_ap_subcriber

    travel_back
    updated.organization.touch

    results = IglooContactsQuery.new.run
    assert_includes results, updated
    assert_not_includes results, not_updated
  end

  test "include a contact if the country has been updated" do
    travel_to 2.years.ago
    updated = create_ap_subcriber
    not_updated = create_ap_subcriber

    travel_back
    updated.country.touch

    results = IglooContactsQuery.new.run
    assert_includes results, updated
    assert_not_includes results, not_updated
  end

  test "include a contact if the organization sector has changed" do
    travel_to 2.years.ago
    updated = create_ap_subcriber
    not_updated = create_ap_subcriber

    travel_back
    updated.organization.sector.touch

    results = IglooContactsQuery.new.run
    assert_includes results, updated
    assert_not_includes results, not_updated
  end

  test "not include all contacts" do
    contact = create(:contact)

    results = IglooContactsQuery.new.run
    assert_not_includes results, contact
  end

  test "includes staff" do
    contact = create_staff_user

    results = IglooContactsQuery.new.run
    assert_includes results, contact
  end

  test "includes a contact subscribed to an action platform" do
    contact = create_ap_subcriber

    results = IglooContactsQuery.new.run
    assert_includes results, contact
  end

  private

  def create_ap_subcriber
    sector = create(:sector)
    organization = create(:organization, sector: sector)
    contact = create(:contact, organization: organization)
    create(:action_platform_subscription, contact: contact)
    contact
  end

end
