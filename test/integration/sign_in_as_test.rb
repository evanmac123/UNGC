require 'test_helper'

class SignInAsTest < ActionDispatch::IntegrationTest

  context 'json autocomplete' do
    setup do
      # Given a Network report recipient
      network = create(:local_network)
      report_recipient = create(:contact, local_network: network, roles: [Role.network_report_recipient])

      # Contact points from an organization in the same local network
      @country = create(:country, local_network: network)
      @macdonalds = create(:organization,
        name: "MacDonald's",
        country: @country,
        state: :approved
      )

      @alice = create(:contact,
        first_name: 'Alice',
        organization: @macdonalds,
        roles: [Role.contact_point]
      )

      @bob = create(:contact,
        first_name: 'Bob',
        organization: @macdonalds,
        roles: [Role.contact_point]
      )

      # Contact points from another organization in the same local network
      @burger_king = create(:organization,
        name: 'Burger King',
        country: @country, state: :approved
      )

      @cathy = create(:contact,
        first_name: 'Cathy',
        organization: @burger_king,
        roles: [Role.contact_point]
      )

      login_as(report_recipient)
    end

    should 'return an empty set without terms' do
      visit admin_sign_in_as_contacts_path()
      response = JSON.parse(page.body)
      assert_equal [], response
    end

    should 'return an empty set when given blank terms' do
      visit admin_sign_in_as_contacts_path(term: '')
      response = JSON.parse(page.body)
      assert_equal [], response
    end

    should 'a list of organizations with the id of the first contact point' do
      visit admin_sign_in_as_contacts_path(term: 'donald')
      response = JSON.parse(page.body)
      assert_contains_contact response, @macdonalds, @alice
    end

    should 'filter on organization name' do
      visit admin_sign_in_as_contacts_path(term: 'ger kin')
      response = JSON.parse(page.body)
      assert_contains_contact response, @burger_king, @cathy
    end

    should 'limit the number of results' do
      101.times do |i|
        similar_name = "Donald #{i} #{Faker::Name.last_name}"
        organization = create(:organization, name: similar_name, country: @country, state: :approved)
        create(:contact, {
          first_name: 'hacks',
          organization: organization,
          roles: [Role.contact_point]
        })
      end

      visit admin_sign_in_as_contacts_path(term: 'donald')
      response = JSON.parse(page.body)
      assert_equal 100, response.count
    end

  end

  private

  def assert_contains_contact(array, organization, contact)
    assert_contains array, {
      "id" => contact.id,
      "contact_name" => contact.name,
      "organization_name" => organization.name,
    }
  end

end
