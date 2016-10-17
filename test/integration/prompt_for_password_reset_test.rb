require 'test_helper'

class PromptForPasswordResetTest < ActionDispatch::IntegrationTest

  setup do
    create_roles
  end

  test "a User with an older password is prompted to change it on login" do
    # Given a contact who needs to change their password
    organization = create(:business)
    contact = create(:contact, last_password_changed_at: nil,
                     organization: organization)

    # When they login
    login_page = TestPage::Login.new
    login_page.visit
    login_page.fill_in_username(contact.username)
    login_page.fill_in_password(contact.password)
    change_password_page = login_page.click_login

    # They are taken to the change password page
    assert_equal change_password_page.path, current_path

    # When they provide a new, valid password, along with their old one
    change_password_page.fill_in_new_password('NewPassw0rd')
    change_password_page.fill_in_password_confirmation('NewPassw0rd')
    change_password_page.fill_in_old_password(contact.password)
    dashboard_page = change_password_page.click_update

    # When they sign out and back in again
    dashboard_page.click_on_logout
    login_page.visit
    login_page.fill_in_username(contact.username)
    login_page.fill_in_password('NewPassw0rd')
    login_page.click_login

    # They should not be prompted to change their password again.
    assert_equal'/admin/dashboard', current_path
  end

  test "with invalid paramters" do
    contact = create_contact
    login_as(contact)

    change_password_page = TestPage::ChangePassword.new(contact)
    change_password_page.visit

    change_password_page.fill_in_new_password('NewPassw0rd')
    change_password_page.fill_in_password_confirmation('NewPassw0rd')
    change_password_page.fill_in_old_password('invalid')
    next_page = change_password_page.click_update

    assert_equal '/', current_path
    assert_equal ['Current password is invalid'], next_page.error_messages
  end

  test "a contact resetting their password" do
    # Given a contact who needs to change their password
    organization = create(:business)
    contact = create(:contact,
                     last_password_changed_at: nil,
                     password: "OldPass0rd",
                     organization: organization)

    # And they have been sent a reset password email
    token = contact.send_reset_password_instructions
    visit edit_contact_password_path(reset_password_token: token)

    # When they enter a new, valid passowrd
    fill_in "New password", with: "NewPassw0rd"
    fill_in "Confirm new password", with: "NewPassw0rd"
    click_on "Change my password"

    # Then they are not asked to enter a new one again
    assert_match(Regexp.new(I18n.t('devise.passwords.updated')), page.html)
    assert_no_match(/Your password must be changed/, page.html, "Expected to not be asked to change password")
  end

  private

  def create_contact
    organization = create(:business)
    create(:contact, last_password_changed_at: nil,
           organization: organization)
  end

end
