require "test_helper"

class Crm::OrganizationSyncTest < ActiveSupport::TestCase

  test ".should_sync" do
    organization = build_stubbed(:organization, sector: build_stubbed(:sector))
    assert Crm::OrganizationSync.should_sync?(organization)
  end

  test "destroying a record that doesn't exist in the CRM" do
    organization = build_stubbed(:organization)
    crm = mock("crm")
    sync = Crm::OrganizationSync.new(crm)
    crm.expects(:find_account).with(organization.id).returns(nil)
    assert_nil sync.destroy(organization.id)
  end

  # TODO This test overlaps with the functional test, merge them
  test "after updating an organization, new contacts are created" do
    contact = create(:contact)
    organization = create(:organization, contacts: [contact])

    crm = mock("crm")
    crm.expects(:log)
    sync = Crm::OrganizationSync.new(crm)

    # first the account is found
    account = Restforce::SObject.new(Id: "account-id")
    crm.expects(:find_account).returns(account)
    crm.expects(:update).with("Account", account.Id, anything).returns(account)

    # the contact is not found
    crm.expects(:find_contact).returns(nil)

    # then it is created
    crm.expects(:create)
      .with("Contact", has_entry("AccountId" => "account-id"))

    sync.update(organization, [])
  end

  # TODO This test overlaps with the functional test, merge them
  test "after creating an organization, existing contacts are updated" do
    contact = create(:contact)
    organization = create(:organization, contacts: [contact])

    crm = mock("crm")
    crm.expects(:log)
    sync = Crm::OrganizationSync.new(crm)

    # first the account is found
    account = Restforce::SObject.new(Id: "account-id")
    crm.expects(:find_account).returns(account)
    crm.expects(:update).with("Account", account.Id, anything).returns(account)

    # the contact is found
    contact = Restforce::SObject.new(Id: "contact-id")
    crm.expects(:find_contact).returns(contact)

    # the first account is created
    crm.expects(:update)
      .with("Contact", "contact-id", has_entry("AccountId" => "account-id"))

    sync.update(organization, [])
  end

end
