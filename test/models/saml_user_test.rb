require "test_helper"

class SamlUserTest < ActiveSupport::TestCase

  test "it allows a valid contact with the matching password" do
    # Given a valid contact
    contact = valid_contact

    # When we authenticate with her username and password
    user = SamlUser.authenticate(contact.username, contact.password)
    # Then we get that contact back indicating the she is authenticated
    assert_equal contact.id, user.id
  end

  test "it denies a valid contact with the wrong password" do
    # Given a valid contact
    contact = valid_contact

    # When we try to authenticate with her username and the wrong password
    user = SamlUser.authenticate(contact.username, "wrong")

    # Then we get nil back indicating that she has not been authenticated
    assert_nil user
  end

  test "it denies a normal contact" do
    # Given a contact
    contact = create(:contact)

    # When we try to authenticate with her username and password
    user = SamlUser.authenticate(contact.username, contact.password)

    # Then we get nil back indicating that she has not been authenticated
    assert_nil user
  end

  test "it denies unknown contacts" do
    # When we try to authenticate a user that doesn't exist
    user = SamlUser.authenticate("doesnt_exist", "Passw0rd")

    # Then we get nil indicating that she has not been authenticated
    assert_nil user
  end

  test "it allows an action platform subscriber" do
    # Given an ActionPlatform
    platform = create(:action_platform_platform)

    # And a contact from an Organization
    organization = create(:organization)
    contact = create(:contact, organization: organization)

    # And a Subscription to that platform for that contact and organization
    create(:action_platform_subscription,
      contact: contact,
      organization: organization,
      platform: platform,
      status: :approved)

    # When we try to authenticate with the contact's username and password
    user = SamlUser.authenticate(contact.username, contact.password)
    # Then we find that contact
    assert_not_nil user
    assert_equal contact.id, user.id
  end

  test "it allows staff to authenticate" do
    # Given a staff contact
    staff = create(:staff_contact)

    # When we authenticate
    user = SamlUser.authenticate(staff.username, staff.password)

    # Then we find their record indicating that they have been authenticated
    assert_not_nil user
    assert_equal staff.id, user.id
  end

  private

  def valid_contact
    ungc = Organization.find_by(name: "UNGC")
    create(:contact, organization: ungc)
  end

end
