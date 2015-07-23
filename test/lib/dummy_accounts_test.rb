require 'test_helper'
require './lib/dummy_accounts'

class DummyAccountsTest < ActiveSupport::TestCase

  setup do
    create_country(code: 'ca', local_network: create_local_network)
    subject = DummyAccounts.new
  end

  [
    :business_organization,
    :non_business_organization,
    :reporting_business_organization,
    :reporting_non_business_organization,
  ].each do |method|
    test "creates #{method}" do
      # creates an organization
      org = subject.public_send(method)
      assert_not_nil org, 'failed to create organization'

      # creates a contact
      contact = org.contacts.first
      assert_not_nil contact, 'failed to create contac'
      assert_not_nil contact.password, 'missing password'

      # should only create 1 organization
      assert_no_difference -> { Organization.count } do
        subject.public_send(method)
      end

      # should only create 1 contact
      assert_no_difference -> { Organization.count } do
        subject.public_send(method)
      end
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

end
