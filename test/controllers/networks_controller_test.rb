require 'test_helper'

class NetworksControllerTest < ActionController::TestCase
  setup do
    create(:container, path: '/engage-locally/europe')

    @local_network = create(:local_network, name: 'Nordic Countries')
    @denmark = create(:country, name: 'Denmark', code: 'DK', local_network_id: @local_network.id)
    @finland = create(:country, name: 'Finland', code: 'FI', local_network_id: @local_network.id)
  end

  test 'should get show' do
    get :show, { region: 'europe', network: @local_network.name.downcase }

    assert_response :success
    assert_not_nil assigns(:page)

    assert_select '.local-network-participants-header a[href=?]', "/what-is-gc/participants/search?#{CGI.escape("search[countries][]")}=#{@denmark.id}&#{CGI.escape("search[countries][]")}=#{@finland.id}"
  end

  test 'should get region' do
    get :region, region: 'europe'

    assert_response :success
    assert_not_nil assigns(:page)
  end
end
