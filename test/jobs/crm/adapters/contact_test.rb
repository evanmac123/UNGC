require "test_helper"

module Crm
  class ContactAdapterTest < ActiveSupport::TestCase

    test "converts UNGC_Contact_ID__c" do
      converted = convert_contact(:create, id: 123)
      assert_equal 123, converted.fetch("UNGC_Contact_ID__c")
    end

    test "converts Salutation" do
      converted = convert_contact(:create, prefix: "Captain")
      assert_equal "Captain", converted.fetch("Salutation")
    end

    test "converts FirstName" do
      converted = convert_contact(:create, first_name: "Alice")
      assert_equal "Alice", converted.fetch("FirstName")
    end

    test "converts LastName" do
      converted = convert_contact(:create, last_name: "Munroe")
      assert_equal "Munroe", converted.fetch("LastName")
    end

    test "converts Title" do
      converted = convert_contact(:create, job_title: "Writer")
      assert_equal "Writer", converted.fetch("Title")
    end

    test "converts organization OwnerId" do
      contact = create(:contact, organization: create(:organization))
      converted = convert_contact(:create, contact)
      assert_equal "005A0000004KjLy", converted.fetch("OwnerId")

      contact.first_name = 'Bobby'
      converted = convert_contact(:update, contact)
      refute converted.has_key?("OwnerId")
    end

    test "converts local_network OwnerId" do
      contact = create(:contact, local_network: create(:local_network))
      converted = convert_contact(:create, contact)
      assert_equal "005A0000004KjLy", converted.fetch("OwnerId")

      contact.first_name = 'Bobby'
      converted = convert_contact(:update, contact)
      refute converted.has_key?("OwnerId")
    end

    test "converts Email" do
      converted = convert_contact(:create, email: "alice@example.com")
      assert_equal "alice@example.com", converted.fetch("Email")
    end

    test "converts Phone" do
      converted = convert_contact(:create, phone: "+1-234-345-4567")
      assert_equal "+1-234-345-4567", converted.fetch("Phone")
    end

    test "truncates phone numbers" do
      long = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQR"
      expected = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJK..."
      converted = convert_contact(:create, phone: long)
      assert_equal expected, converted.fetch("Phone")
    end

    test "converts MobilePhone" do
      converted = convert_contact(:create, mobile: "+1-234-345-4567")
      assert_equal "+1-234-345-4567", converted.fetch("MobilePhone")
    end

    test "converts Fax" do
      converted = convert_contact(:create, fax: "+1-234-345-4567")
      assert_equal "+1-234-345-4567", converted.fetch("Fax")
    end

    test "converts MailingStreet" do
      contact = create(:contact, address: "15240 Runte Turnpike", address_more: "Suite 123")
      converted = convert_contact(:create, contact)
      assert_equal "15240 Runte Turnpike\nSuite 123", converted.fetch("MailingStreet")

      contact.first_name = 'Bobby'
      converted = convert_contact(:update, contact)
      refute converted.has_key?("MailingStreet")

      contact.address = 'Turnpike'
      converted = convert_contact(:update, contact)
      assert_equal "Turnpike\nSuite 123", converted.fetch("MailingStreet")

      contact.address_more = 'Suite'
      converted = convert_contact(:update, contact)
      assert_equal "Turnpike\nSuite", converted.fetch("MailingStreet")
    end

    test "truncates MailingStreet when it's too long" do
      contact = create(:contact,
        address: Faker::Lorem.characters(200),
        address_more: Faker::Lorem.characters(200))

      converted = convert_contact(:create, contact)
      assert_equal 255, converted.fetch("MailingStreet").length
    end

    test "converts MailingCity" do
      converted = convert_contact(:create, city: "Nelson Mandela Bay Metropolitan Municipality")
      assert_equal "Nelson Mandela Bay Metropolitan Munic...", converted.fetch("MailingCity")
    end

    test "converts MailingState" do
      converted = convert_contact(:create, state: "Ontario")
      assert_equal "Ontario", converted.fetch("MailingState")
    end

    test "converts MailingPostalCode" do
      converted = convert_contact(:create, postal_code: "90210")
      assert_equal "90210", converted.fetch("MailingPostalCode")
    end

    test "truncates MailingPostalCode" do
      converted = convert_contact(:create, postal_code: "123456789012345678901234567890")
      assert_equal "12345678901234567...", converted.fetch("MailingPostalCode")
    end

    test "converts MailingCountry" do
      canada = build_stubbed(:country, name: "Canada")
      contact = create(:contact, country: canada)
      converted = convert_contact(:create, contact)
      assert_equal "Canada", converted.fetch("MailingCountry")

      contact.first_name = 'Bobby'
      converted = convert_contact(:update, contact)
      refute converted.has_key?("MailingCountry")

      usa = build_stubbed(:country, name: "USA")
      contact.country = usa
      converted = convert_contact(:udpate, contact)
      assert_equal "USA", converted.fetch("MailingCountry")
    end

    test "converts Role__c" do
      contact = create(:contact, roles: Role.all)
      converted = convert_contact(:create, contact)
      names = Role.pluck(:name).join(";")
      assert_equal names, converted.fetch("Role__c")

      contact.roles = [Role.ceo]
      converted = convert_contact(:update, contact)
      names = Role.ceo.name
      assert_equal names, converted.fetch("Role__c")

    end

    test "converts npe01__PreferredPhone__c" do
      contact = create(:contact)
      converted = convert_contact(:create, contact)
      assert_equal "Work", converted.fetch("npe01__PreferredPhone__c")

      contact.first_name = 'Bobby'
      converted = convert_contact(:update, contact)
      refute converted.has_key?("npe01__PreferredPhone__c")
    end

    private

    def convert_contact(action, params = {})
      contact = if params.respond_to?(:id)
                  params # it is an contact
                else
                  create(:contact, params)
                end
      Crm::Adapters::Contact.new(contact, action, contact.changes).crm_payload
    end
  end

end
