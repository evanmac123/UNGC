# frozen_string_literal: true

require "test_helper"

class Academy::ViewerInvitationJobTest < ActiveSupport::TestCase

  test "it invites participant contacts without a login" do
    # Given a contact without a username/password
    contact = create(:contact, username: nil, encrypted_password: nil)

    # When we invite them
    Academy::ViewerInvitationJob.perform_now(contact)
    contact.reload

    # Then they are assigned a username
    assert_not_nil contact.username

    # And they are assigned a password reset token
    assert_not_nil contact.reset_password_token

    # And they are in the Academy role
    assert contact.is?(Role.academy_viewer), "Contact should have the Academy role"

    # And they are sent a welcome email
    # With the username and password in it.
    email = ActionMailer::Base.deliveries.last
    assert_not_nil email
    html = email.html_part.body.to_s
    text = email.text_part.body.to_s

    assert_match /Username: #{contact.username}/, text
    assert_match /Username: #{contact.username}/, html
  end

  test "it saves older contacts that don't pass validations anymore" do
    contact = build(:contact, prefix: nil)
    refute contact.valid?
    contact.save!(validate: false)

    Academy::ViewerInvitationJob.perform_now(contact)
    assert_not_nil contact.username
    assert contact.persisted?
  end

end
