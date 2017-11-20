require 'test_helper'

class LocalNetworkTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should have_many :countries
  should have_many :contacts

  test "should reject invalid large url" do
    local_network = create(:local_network)
    local_network.url = "http://goodlink.com/B3lBn76KKzCmOvp7EVomvPSEsiwsE3Bo0H1WhhyZK6Xq5Co2wL0W2x8swBpqOvJ1xiUcUhBNnDuIceTTNyJa5Yj1q4qinFYBpg4VXbYiOeehI9G2V3oJjhiBWqS05YSHQyZBAKGcnO7njnL9A1vq5kBNB01yBSCIZ3Lb4uDMfZScmv7KMgrsGixzq46aL3IJQW8MH37loOlMU4NPVWAh0HMlMUDlDQsf48T9895kbtZ7z8JDYs8WUXsyNlrwcTv1"
    assert_not local_network.valid?
  end


  context 'state lists' do
    should 'be complete' do
      states = [
          :emerging,
          :active,
          :advanced,
          :inactive,
          :regional_center,
      ]

      assert_equal states.reject { |key| key == :regional_center }, LocalNetwork::NO_REGIONAL_CENTER_STATES
      assert_equal states.reject { |key| key == :inactive }, LocalNetwork::LN_ACTIVE_STATES
    end
  end

  context 'scopes' do
    should "correctly filter Organizations" do
      emerging = create(:local_network, state: :emerging)
      active = create(:local_network, state: :active)
      advanced = create(:local_network, state: :advanced)
      inactive = create(:local_network, state: :inactive)
      regional = create(:local_network, state: :regional_center)

      result = LocalNetwork.no_regional_centers.order(:id).pluck(:id)

      assert_includes result, emerging.id
      assert_includes result, active.id
      assert_includes result, advanced.id
      assert_includes result, inactive.id
      assert_not_includes result, regional.id


      result = LocalNetwork.active_networks.order(:id).pluck(:id)

      assert_includes result, emerging.id
      assert_includes result, active.id
      assert_includes result, advanced.id
      assert_includes result, regional.id
      assert_not_includes result, inactive.id
    end
  end
end