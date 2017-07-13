require "test_helper"

class DonationIntegrationTest < JavascriptIntegrationTest

  setup { FakeStripe.stub_stripe }
  teardown { FakeStripe.reset }

  test "submitting a donation" do
    skip
    # Given I am logged in as an organization user
    contact = create_organization_user
    login_as(contact)

    # When I visit the donation form
    visit(new_donation_path(organization_id: contact.organization_id))

    # And fill in the amount and my credit card details
    fill_in("Annual contribution amount", with: "$12,345.67")
    fill_in("Card Number", with: "4242 4242 4242 4242")
    fill_in("Month (MM)", with: "12")
    fill_in("Year (YY)", with: "18")
    fill_in("CVC", with: "123")
    fill_in("Invoice number", with: contact.organization_id.to_s+"#TEST1234")
    select("Visa", from: "Credit card type")

    # And submit
    click_on "Contribute"

    # HACK to make sure the javascript runs long enough to get the token
    page.has_css?("#new_donation.submitted")

    # Then I should see that my donation is accepted for the proper amount
    assert page.has_content?("Your donation of $12,345.67 has been accepted.")
  end

  test "after a business is approved, they follow the donation link in their welcome email" do
    # Given a business has been approved and they have been sent their
    contact = create(:contact, roles: [Role.contact_point])
    business = create(:business, contacts: [contact])
    email = OrganizationMailer.approved_business(business)

    # And a page exists
    payload = create(:payload, data: {})
    create(:container, path: "/about/foundation", layout: :article,
           public_payload: payload)

    # And the contact point clicks on the link
    donation_link = find_donation_link(email.body)
    visit donation_link

    # Then they are on the /about/foundation page
    assert_equal "/about/foundation", current_path

    # When they click on "Contribute by credit card"
    click_on "Contribute by Credit Card"

    # Then they are on the new donation form
    assert_equal new_donation_path, current_path

    # And their contact info is pre-filled
    assert_equal contact.id.to_s, find("input[name='donation[contact_id]']").value
    assert_equal contact.first_name, find_field("First name").value

    # And the business id is pre-filled
    assert_equal business.id.to_s, find("input[name='donation[organization_id]']").value
    assert_equal business.name, find_field("Company name").value
  end

  private

  def find_donation_link(body)
    doc = Nokogiri::HTML(body.to_s)
    donation_link = doc.css("a[role='donation-link']").first
    uri = URI.parse(donation_link["href"])
    [uri.path, uri.query].join("?")
  end

  def create_organization_user
    contact = create_organization_and_user
    contact.update!(state: "Ontario", postal_code: "90210")
    contact.organization.update!(revenue: 3)
    contact
  end

end
