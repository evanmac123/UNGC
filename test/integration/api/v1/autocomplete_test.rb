require 'test_helper'

class Api::V1::AutocompleteTest < ActionDispatch::IntegrationTest

  should "autocomplete participants" do
    food_times = create(:organization, name: 'Foods R Us', active: false, participant: true)
    food_times = create(:organization, name: 'Food Times', active: true, participant: true)
    acme_foods = create(:organization, name: 'ACME Foods', active: true, participant: true)

    visit '/api/v1/autocomplete/participants.json?term=ood'
    assert_equal 200, page.status_code

    expected = [
      {
        'id' => acme_foods.id,
        'label' => 'ACME Foods',
        'value' => 'ACME Foods',
      },
      {
        'id' => food_times.id,
        'label' => 'Food Times',
        'value' => 'Food Times',
      },
    ]

    json_body = JSON.parse(page.body)
    assert_equal expected, json_body
  end

  should "autocomplete countries" do
    create(:country, name: 'Canada')
    usa = create(:country, name: 'United States of America')
    uae = create(:country, name: 'United Arab Emirates')

    visit '/api/v1/autocomplete/countries.json?term=nited'
    assert_equal 200, page.status_code

    expected = [
      {
        'id' => uae.id,
        'label' => 'United Arab Emirates',
        'value' => 'United Arab Emirates',
      },
      {
        'id' => usa.id,
        'label' => 'United States of America',
        'value' => 'United States of America',
      }
    ]

    json_body = JSON.parse(page.body)
    assert_equal expected, json_body
  end

end
