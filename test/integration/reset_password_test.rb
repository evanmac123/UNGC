require 'test_helper'

class ResetPasswordTest < ActionDispatch::IntegrationTest

  should "reset the user's password" do
    login_as(contact)
    visit admin_path

    click_on "Edit profile"
    assert_equal edit_contact_registration_path, current_path

    fill_in 'contact_password', with: 'new_password'
    fill_in 'contact_password_confirmation', with: 'new_password'
    fill_in 'contact_current_password', with: 'old_password'

    click_on 'Update'

    assert contact.reload.valid_password?('new_password'), 'failed to update password'
  end

  private

  def contact
    @contact ||= create_contact(
      country: country,
      organization: organization,
      password: 'old_password'
    )
  end

  def organization
    @organization ||= create_organization(
      country: country,
      organization_type: create_organization_type
    )
  end

  def country
    @country ||= create_country
  end

end
