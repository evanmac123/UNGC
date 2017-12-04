# -*- coding: utf-8 -*-
require "test_helper"

class Donation::FormTest < ActiveSupport::TestCase

  test "defaults first_name" do
    form = create_form(first_name: "First")
    assert_equal "First", form.first_name
  end

  test "defaults last_name" do
    form = create_form(last_name: "Last")
    assert_equal "Last", form.last_name
  end

  test "defaults address" do
    form = create_form(address: "123 Green St.")
    assert_equal "123 Green St.", form.address
  end

  test "defaults address_more" do
    form = create_form(address_more: "Suite 123")
    assert_equal "Suite 123", form.address_more
  end

  test "defaults city" do
    form = create_form(city: "Toronto")
    assert_equal "Toronto", form.city
  end

  test "defaults state" do
    form = create_form(state: "Ontario")
    assert_equal "Ontario", form.state
  end

  test "defaults postal_code" do
    form = create_form(postal_code: "90210")
    assert_equal "90210", form.postal_code
  end

  test "defaults country_name" do
    france = build_stubbed(:country, name: "France")
    form = create_form(country: france)
    assert_equal "France", form.country_name
  end

  test "defaults email_address" do
    form = create_form(email: "foo@example.com")
    assert_equal "foo@example.com", form.email_address
  end

  test "defaults id" do
    form = create_form(id: 123)
    assert_equal 123, form.contact_id
  end

  test "defaults name_on_card" do
    form = create_form(first_name: "Foo", last_name: "Bar")
    assert_equal "Foo Bar", form.name_on_card
  end

  test "validates token" do
    contact = build(:contact, state: "ON", postal_code: "90210")
    form = Donation::Form.from(contact: contact)
    assert_not form.valid?
    assert_includes form.errors.full_messages,
      " We were unable to process your donation"
  end

  test "creates a reference" do
    form = Donation::Form.new
    assert_not_nil form.reference
  end

  test "formats amount when there is a value" do
    donation = Donation::Form.new(amount: 1234)
    assert_equal "$1,234.00", donation.formatted_amount
  end

  test "formats amount when there is no value" do
    donation = Donation::Form.new(amount: nil)
    assert_nil donation.formatted_amount
  end

  test "rejects donation if amount is less than 50 cents" do
    donation = build(:donation_form, amount: 0.45)
    refute donation.valid?
    assert_contains donation.errors.full_messages, "Amount must be at least 50 cents"
  end

  test "accepts donation if amount is less than 50 cents" do
    donation = build(:donation_form, amount: 0.50)
    assert donation.valid?, donation.errors.full_messages
  end

  test "defaults organization details when the contact is from an organization" do
    contact, _ = create_contact_from_organization(
      organization_params: { name: "Foo Corp", revenue: 4 }
    )
    form = Donation::Form.from(contact: contact)

    assert contact.from_organization?
    assert_equal "Foo Corp", form.company_name
  end

  test "organization_id is required" do
    form = build(:donation_form, organization_id: nil)

    refute form.valid?
    assert_includes form.errors.full_messages, "Organization can't be blank"
  end

  test "organization_id must be a valid organization" do
    form = build(:donation_form, organization_id: 123)

    refute form.valid?
    assert_includes form.errors.full_messages, "Organization can't be blank"
  end

  test "invoice number is required" do
    form = build(:donation_form, invoice_number: nil)
    assert form.valid?, form.errors.full_messages
  end

  test "invoice number accepts UTF-8 characters" do
    organization = build_stubbed(:organization)
    form = build(:donation_form, organization: organization,
      invoice_number: " #{organization.id} ‒ 78 | 88",
    )
    assert form.valid?, form.errors.full_messages
  end

  test "organization_id is defaulted by the contact's organization" do
    contact, organization = create_contact_from_organization
    form = Donation::Form.from(contact: contact)
    assert_equal organization.id, form.organization_id
  end

  test "matches the contact" do
    contact, organization = create_contact_from_organization

    form = build(:donation_form,
                 contact_id: nil,
                 first_name: contact.first_name,
                 last_name: contact.last_name,
                 email_address: contact.email,
                 organization: organization)

    assert_equal contact.id, form.contact_id
  end

  test "does not require a contact" do
    form = build(:donation_form, contact_id: nil)

    assert form.valid?
  end

  private

  def create_contact_from_organization(contact_params: {}, organization_params: {})
    organization = create(:organization, organization_params)
    contact = create(:contact, contact_params.reverse_merge(
      organization: organization,
      postal_code: "90210",
      state: "California"
    ))
    [contact, organization]
  end

  def create_form(contact_params = {})
    contact = build_stubbed(:contact, contact_params)
    Donation::Form.from(contact: contact)
  end

end
