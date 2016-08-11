require 'test_helper'

class Api::V1::OrganizationsTest < ActionDispatch::IntegrationTest

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

    expected = [
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
        "profile_url" => "https://www.example.com/what-is-gc/participants/#{o.id}-Lasers-n-Sharks",
        "is_local_network_member" => true,
        "is_deleted" => false,
        "created_at" => o.created_at,
        "updated_at" => o.updated_at,
        "organization_type" => {
          "name" => "SME",
          "type" => "Business"
        }
      }
    ]

    ap :Expected
    ap expected
    ap :Actual
    ap json_response

    assert_equal expected, json_response
  end

end
