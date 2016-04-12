require 'test_helper'

class EngageLocallyRegionPageTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelper

  setup do
    create_staff_user

    # we need a network and a country to display the networks
    country = create(:country, name: 'egypt', region: 'africa')
    @ln = create(:local_network, state: 'active', countries: [country])

    container = create(:container,
      path: 'engage-locally/africa',
      layout: 'engage_locally'
    )
    payload = load_payload(:engage_locally)

    payload['widget_contact']['contact_id'] = update_contact_with_image(@staff_user).id
    @related_contents = create_related_contents_component_data
    @resources,payload['resources'] = create_resource_content_block_data_and_payload
    @events,@news = create_event_news_component_data

    container.create_public_payload(
      container_id: container.id,
      json_data: payload.to_json
    )
    container.save

    get '/engage-locally/africa'

    @data = container.public_payload.data
  end

  should 'respond successfully' do
    assert_response :success
  end

  should 'render content' do
    assert_select_html '.region-networks-list', @ln.name
  end

end
