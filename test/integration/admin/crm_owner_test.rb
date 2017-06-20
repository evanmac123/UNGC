require "test_helper"
require "rake"

class Admin::CrmOwnerTest < ActionDispatch::IntegrationTest

  test "it handles crm owners" do
    ungc = Organization.find_by(name: "UNGC")
    contact = create(:contact, first_name: "Bob", last_name: "Ross",
      organization: ungc)

    login_as contact

    visit dashboard_path
    within("#crm_owners") do
      click_on "CRM Owners"
    end

    click_on "New Owner"
    fill_in "Participant Manager", with: "Bob Ross"

    # Cheat with autocomplete
    find(:xpath, "//input[@id='crm_owner_contact_id']").set(contact.id)

    fill_in "Salesforce ID", with: "ABC123"
    click_on "Save"

    assert_has_owner "Bob Ross", with_id: "ABC123"
    all("*", text: "Bob Ross").last.click

    fill_in "Salesforce ID", with: "DEF456"
    click_on "Save"

    assert_has_owner "Bob Ross", with_id: "DEF456"

    click_on "Delete"

    assert_has_no_owner "Bob Ross"
  end

  private

  def assert_has_owner(name, with_id:)
    assert page.has_content? name
    assert page.has_content? with_id
  end

  def assert_has_no_owner(name)
    assert_not page.has_content? name
  end

end
