require 'test_helper'

class NetworksControllerTest < ActionController::TestCase
  setup do
    create_container path: '/engage-locally/north-america'

    @local_network = create_local_network(name: 'Canada')
    @country = create_country(name: 'Canada', code: 'CA', local_network_id: @local_network.id)
  end

  test 'should get show' do
    get :show, { region: 'north-america', network: @local_network.name.downcase }

    assert_response :success
    assert_not_nil assigns(:page)
  end

  test 'should get region' do
    get :region, region: 'north-america'

    assert_response :success
    assert_not_nil assigns(:page)
  end
end
