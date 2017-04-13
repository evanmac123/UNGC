require 'test_helper'

class IglooContactsQueryTest < ActiveSupport::TestCase

  should "include a contact" do
    contact = create(:contact, updated_at: 3.minutes.ago)
    results = IglooContactsQuery.new.run
    assert_includes results, contact
  end

  should "not include a contact that was updated more than 5 mins ago" do
    contact = create(:contact, updated_at: 10.minutes.ago)
    results = IglooContactsQuery.new.run
    assert_empty results, contact
  end

  should "include contact if organization name is updated" do
    date = Date.new(2015,02,12)
    organization = create(:organization, created_at: date, updated_at: date)
    contact = create(:contact, created_at: date, updated_at: date, organization: organization)
    organization.name = "Super Cool Company"
    organization.save!
    assert organization.updated_at > 5.minutes.ago, "organization has not been updated in the last 5 minutes"
    results = IglooContactsQuery.new.updated_organization
    assert_includes results, contact
  end

end
