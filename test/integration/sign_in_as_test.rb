require 'test_helper'

class SignInAsTest < ActionDispatch::IntegrationTest

  setup { create_roles }

  # TODO express these tests in a way that works with the javascript_tag
  # phantomjs?
  # context 'Signing in as another contact' do
  #
  #   should 'Allow a network report recipient to sign-in as a contact point from the same local network' do
  #     # Given a Network report recipient
  #     network = create_local_network
  #     report_recipient = create_contact(local_network: network, roles: [Role.network_report_recipient])
  #
  #     # and a Contact points from an organization in the same local network
  #     country = create_country(local_network: network)
  #     organization = create_organization(country: country, state: :approved)
  #     contact_point = create_contact(
  #       first_name: 'Bob',
  #       last_name: 'Redmill',
  #       organization: organization,
  #       roles: [Role.contact_point]
  #     )
  #
  #     login_as(report_recipient)
  #     visit('/admin/dashboard')
  #
  #     click_on 'Sign-in'
  #     assert_equal "You have been signed in as Bob Redmill", find('.flash.notice').text
  #   end
  #
  #   should 'Disallow unauthorized contacts from signing-in as another contact' do
  #     network_contact = create_contact(local_network: create_local_network)
  #
  #     login_as(network_contact)
  #     visit('/admin/dashboard')
  #
  #     hidden_id_field = find '#sign_in_as_id'
  #     hidden_id_field.set create_contact.id
  #
  #     click_on 'Sign-in'
  #     assert_equal "Unauthorized", find('.flash.notice').text
  #   end
  #
  # end

  context 'json autocomplete' do
    setup do
      # Given a Network report recipient
      network = create_local_network
      report_recipient = create_contact(local_network: network, roles: [Role.network_report_recipient])

      # Contact points from an organization in the same local network
      @country = create_country(local_network: network)
      @macdonalds = create_organization(
        name: "MacDonald's",
        country: @country,
        state: :approved
      )

      @alice = create_contact(
        first_name: 'Alice',
        organization: @macdonalds,
        roles: [Role.contact_point]
      )

      @bob = create_contact(
        first_name: 'Bob',
        organization: @macdonalds,
        roles: [Role.contact_point]
      )

      # Contact points from another organization in the same local network
      @burger_king = create_organization(
        name: 'Burger King',
        country: @country, state: :approved
      )

      @cathy = create_contact(
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
      101.times {
        similar_name = "Donald #{FixtureReplacement.random_string(8)}"
        organization = create_organization(name: similar_name, country: @country, state: :approved)
        create_contact(
          first_name: 'hacks',
          organization: organization,
          roles: [Role.contact_point]
        )
      }

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
