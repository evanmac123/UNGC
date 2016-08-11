require 'test_helper'

class Api::V1::OrganizationsTest < ActionDispatch::IntegrationTest

  test "/api/v1/organizations" do
    local_network = create(:local_network)
    country = create(:country, local_network: local_network)
    sector = create(:sector)
    o = create(:business,
               state: 'approved',
               participant: true,
               sector: sector,
               country: country
              )
    get '/api/v1/organizations.json'
    assert_response :success
    json_response = JSON.parse(response.body)
    ap json_response
    expected = [
      {
        "id" => o.id,
        "name" => o.name,
        "country_name" => o.country.name,
        "revenue" => o.revenue,
        "employees" => o.employees,
        "created_at" => o.created_at,
        "updated_at" => o.updated_at,
        "cop_state" => o.cop_state,
        "url" => o.url,
        "sector_id" => o.sector_id,
        "is_local_network_member" => o.is_local_network_member,
        "organization_type" => {
          "name" => "SME",
          "type" => "Business"
        },
        "local_network" => {
          "name" => "Canada",
          "url" => "blah.com"
        }

      },
    ]

    assert_equal expected, json_response
  end

end
