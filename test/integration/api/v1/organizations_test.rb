require 'test_helper'

class Api::V1::OrganizationsTest < ActionDispatch::IntegrationTest

  setup     { travel_to Time.zone.local(2016, 8, 11, 12, 43, 3) }
  teardown  { travel_back }

  test "/api/v1/organizations" do
    local_network = create(:local_network)
    country = create(:country, local_network: local_network, name: "France")
    sector = create(:sector, name: "Animal Wellfare")

    organization_type = create(:organization_type,
                               name: "SME",
                               type_property: OrganizationType::BUSINESS)

    o = create(:organization,
               name: "Lasers n' Sharks",
               revenue: 4,
               employees: 43,
               cop_state: 'delisted',
               state: 'approved',
               url: "https://lasers-n-sharks.info",
               participant: true,
               sector: sector,
               country: country,
               is_local_network_member: true,
               organization_type: organization_type
              )

    get '/api/v1/organizations.json'
    assert_response :success
    json_response = JSON.parse(response.body)

    expected = {
      'organizations' => [
        {
          "id" => o.id,
          "name" => "Lasers n' Sharks",
          "participant" => true,
          "country_name" => "France",
          "revenue" => "between USD 1 billion and USD 5 billion",
          "employees" => 43,
          "cop_state" => "delisted",
          "url" => "https://lasers-n-sharks.info",
          "sector_name" => "Animal Wellfare",
          "profile_url" => "http://www.unglobalcompact.org/what-is-gc/participants/#{o.id}-Lasers-n-Sharks",
          "is_local_network_member" => true,
          "is_deleted" => false,
          "created_at" => "2016-08-11T12:43:03.000Z",
          "updated_at" => "2016-08-11T12:43:03.000Z",
          "organization_type" => {
            "name" => "SME",
            "type" => "Business"
          }
        }
      ]
    }

    assert_equal expected, json_response
  end

  test "filter organization by climate initiative" do
    # Given an organization which has signed the climate initiative
    signed = create(:business, name: "We signed")
    climate_id = Initiative::FILTER_TYPES[:climate]
    climate = create(:initiative, id: climate_id)
    create(:signing, organization: signed, initiative: climate)

    # And one who hasn't
    hasnt = create(:business, name: "We haven't")

    get '/api/v1/organizations.json?initiative=climate'

    json_response = JSON.parse(response.body)
    organizations = json_response['organizations']
    assert_equal 1, organizations.length
    assert_equal organizations.first['name'], "We signed"
  end

end
