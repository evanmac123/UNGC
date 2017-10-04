require "test_helper"

module Crm
  class ContactAdapterTest < ActiveSupport::TestCase

    test "converts UNGC_Contact_ID__c" do
      converted = convert_contact(id: 123)
      assert_equal 123, converted.fetch("UNGC_Contact_ID__c")
    end

    test "converts Salutation" do
      converted = convert_contact(prefix: "Captain")
      assert_equal "Captain", converted.fetch("Salutation")
    end

    test "converts FirstName" do
      converted = convert_contact(first_name: "Alice")
      assert_equal "Alice", converted.fetch("FirstName")
    end

    test "converts LastName" do
      converted = convert_contact(last_name: "Munroe")
      assert_equal "Munroe", converted.fetch("LastName")
    end

    test "converts Title" do
      converted = convert_contact(job_title: "Writer")
      assert_equal "Writer", converted.fetch("Title")
    end

    test "converts OwnerId" do
      converted = convert_contact
      assert_equal "005A0000004KjLy", converted.fetch("OwnerId")
    end

    test "converts Email" do
      converted = convert_contact(email: "alice@example.com")
      assert_equal "alice@example.com", converted.fetch("Email")
    end

    test "converts Phone" do
      converted = convert_contact(phone: "+1-234-345-4567")
      assert_equal "+1-234-345-4567", converted.fetch("Phone")
    end

    test "truncates phone numbers" do
      long = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQR"
      expected = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJK..."
      converted = convert_contact(phone: long)
      assert_equal expected, converted.fetch("Phone")
    end

    test "converts MobilePhone" do
      converted = convert_contact(mobile: "+1-234-345-4567")
      assert_equal "+1-234-345-4567", converted.fetch("MobilePhone")
    end

    test "converts Fax" do
      converted = convert_contact(fax: "+1-234-345-4567")
      assert_equal "+1-234-345-4567", converted.fetch("Fax")
    end

    test "converts MailingStreet" do
      converted = convert_contact(address: "15240 Runte Turnpike",
        address_more: "Suite 123")
      assert_equal "15240 Runte Turnpike\nSuite 123", converted.fetch("MailingStreet")
    end

    test "converts MailingCity" do
      converted = convert_contact(city: "Nelson Mandela Bay Metropolitan Municipality")
      assert_equal "Nelson Mandela Bay Metropolitan Munic...", converted.fetch("MailingCity")
    end

    test "converts MailingState" do
      converted = convert_contact(state: "Ontario")
      assert_equal "Ontario", converted.fetch("MailingState")
    end

    test "converts MailingPostalCode" do
      converted = convert_contact(postal_code: "90210")
      assert_equal "90210", converted.fetch("MailingPostalCode")
    end

    test "truncates MailingPostalCode" do
      converted = convert_contact(postal_code: "123456789012345678901234567890")
      assert_equal "12345678901234567...", converted.fetch("MailingPostalCode")
    end

    test "converts MailingCountry" do
      canada = build_stubbed(:country, name: "Canada")
      converted = convert_contact(country: canada)
      assert_equal "Canada", converted.fetch("MailingCountry")
    end

    test "converts Role__c" do
      converted = convert_contact(roles: Role.all)
      names = Role.pluck(:name).join(";")
      assert_equal names, converted.fetch("Role__c")
    end

    test "converts npe01__PreferredPhone__c" do
      converted = convert_contact
      assert_equal "Work", converted.fetch("npe01__PreferredPhone__c")
    end

    private

    def convert_contact(params = {})
      contact = if params.respond_to?(:id)
                  params # it is an contact
                else
                  build_stubbed(:contact, params)
                end
      adapter = Crm::ContactAdapter.new
      adapter.to_crm_params(contact)
    end
  end

end
