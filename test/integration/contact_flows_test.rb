require 'test_helper'

class ContactFlowsTest < ActionDispatch::IntegrationTest
  setup do
    create_roles # Needed by create new contact
    create(:country, name: 'United States of America' )# Needed by create new contact
    @ungc_contact = create_staff_user
    @ungc_organization = @ungc
  end

  test 'contact flow' do
    # sign in
    visit '/login'
    fill_in 'Username', with: @ungc_contact.username
    fill_in 'Password', with: @ungc_contact.password
    click_on 'Login'
    assert_equal dashboard_path, current_path

    # navigate to UNGC organization
    visit admin_organization_path(@ungc_organization)
    assert_equal admin_organization_path(@ungc_organization), current_path

    # navigate to new contact form
    click_on 'New Contact'

    assert_equal new_admin_organization_contact_path(@ungc_organization.id), current_path

    # create new contact
    fill_in 'contact_prefix', with: 'Mr.'
    fill_in 'contact_first_name', with: 'Venu'
    fill_in 'contact_last_name', with: 'Keesari'
    fill_in 'contact_job_title', with: 'Communications and Web Development'
    fill_in 'contact_email', with: 'keesari@unglobalcompact.org'
    fill_in 'contact_address', with: '2 UN Plaza DC2-612'
    fill_in 'contact_city', with: 'New York'
    fill_in 'contact_state', with: 'NY'
    select 'United States of America', :from => 'contact_country_id'
    assert_difference 'Contact.count', 1 do
      click_on 'Create'
    end
    assert_equal admin_organization_path(@ungc_organization.id), current_path
    assert_equal 'Contact was successfully created.', find('.flash.notice').text

    # navigate to edit contact
    contact = Contact.find_by_first_name 'Venu'
    visit edit_admin_organization_contact_path(@ungc_organization, contact)
    assert_equal edit_admin_organization_contact_path(@ungc_organization, contact), current_path

    # update contact
    fill_in 'contact_phone', with: '+1 555 555 1234'
    click_on 'Save changes'
    assert_equal admin_organization_path(@ungc_organization).gsub('-UNGC',''), current_path
    assert_equal 'Contact was successfully updated.', find('.flash.notice').text
    contact.reload
    assert_equal '+1 555 555 1234', contact.phone
  end
end
