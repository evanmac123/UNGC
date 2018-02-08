require 'test_helper'
require './lib/dummy_accounts'

class DummyAccountsTest < ActiveSupport::TestCase

  setup do
    create_listing_statuses
    create_staff_user
    create(:country, code: 'CA', local_network: create(:local_network))
    subject = DummyAccounts.new
  end

  test 'creates a business_organization' do
    assert_creates_organization_and_user do
      subject.business_organization
    end
  end

  test 'creates a non_business_organization' do
    assert_creates_organization_and_user do
      subject.non_business_organization
    end
  end

  test 'creates a reporting_business_organization' do
    assert_creates_organization_and_user do
      subject.reporting_business_organization
    end
  end

  test 'creates a reporting_non_business_organization' do
    assert_creates_organization_and_user do
      subject.reporting_non_business_organization
    end
  end

  [
    :local_network_account,
    :reporting_local_network_account,
  ].each do |method|
    test "creates #{method}" do
      contact = subject.public_send(method)
      assert_not_nil contact, 'failed to create contact'
      assert_not_nil contact.local_network, 'missing local network'
      assert_not_nil contact.password, 'missing password'
    end
  end

  private

  def assert_creates_organization_and_user
    # creates an organization
    org = yield
    assert_not_nil org, 'failed to create organization'

    # creates a contact
    contact = org.contacts.first
    assert_not_nil contact, 'failed to create contac'
    assert_not_nil contact.password, 'missing password'

    # should pass through the OrganizationUpdater
    reg = org.registration
    updater = OrganizationUpdater.new(org.attributes, reg.attributes)
    assert updater.update(org, @staff_user), updater.error_message

    # should not create a second instance of organization
    assert_no_difference 'Organization.count' do
      yield
    end

    # should not create a second instance of contact
    assert_no_difference 'Organization.count' do
      yield
    end
  end

  def create_organization_types
    create(:organization_type,
      name: 'Academic',
      type_property: OrganizationType::NON_BUSINESS
    )
    create(:organization_type,
      name: 'SME',
      type_property: OrganizationType::BUSINESS
    )
  end

  def create_listing_statuses
    create(:listing_status, name: "Not Applicable")
    create(:listing_status, name: "Publicly Listed")
  end

end
