require "test_helper"

class LocalNetworkPageTest < ActiveSupport::TestCase
  test "#participants_by_sector" do
    sector = create(:sector)
    local_network = create(:local_network)
    country = create(:country, local_network: local_network)
    create(:organization, :active_participant, sector: sector, country: country)

    page = LocalNetworkPage.new(local_network)

    assert_equal local_network.name, page.meta_title
    assert_equal page.participants.list.length, 1
  end
end
