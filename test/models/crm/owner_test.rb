require "test_helper"

class Crm::OwnerTest < ActiveSupport::TestCase

  test "converts known owner" do
    contact = create(:contact,
                   id: 121481,
                   first_name: "Thorin",
                   last_name: "Schriber")
    Crm::Owner.create!(contact: contact, crm_id: "00512000005yehm")

    assert_equal "00512000005yehm", Crm::Owner.owner_id(contact.id)
  end

  test "converts substitute owner" do
    create(:contact,
           id: 18334,
           first_name: "Gordana",
           last_name: "Filipic")

    contact = create(:contact,
                   id: 226681,
                   first_name: "GC",
                   last_name: "Africa")

    Crm::Owner.create!(contact: contact, crm_id: '005A00000039Eu7')

    assert_equal "005A00000039Eu7", Crm::Owner.owner_id(contact.id)
  end

  test "converts default owner" do
    contact = create(:contact,
                   id: 12345,
                   first_name: "NotIn",
                   last_name: "Salesforce")

    assert_equal "005A0000004KjLy", Crm::Owner.owner_id(contact.id)
  end
end
