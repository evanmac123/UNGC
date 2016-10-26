require 'test_helper'

class CopMailerHelperTest < ActionView::TestCase
  context 'given #link_to_local_network' do
    setup do
      create_organization_and_user
    end

    context 'with an organization with a local network country code' do
      setup do
        @organization.country.update(region: 'northern_america', local_network_id: LocalNetwork.create(name: 'Foo').id)
      end

      should 'return a URL to the local network' do
        assert_match /^http:\/\/[a-z0-9\.\:]+\/engage\-locally\/north\-america\/foo$/, link_to_local_network(@organization)
      end
    end

    context 'with an organization without a local network country code' do
      should 'return a URL to the local network index' do
        assert_match /^http:\/\/[a-z0-9\.\:]+\/engage\-locally$/, link_to_local_network(@organization)
      end
    end
  end
end
