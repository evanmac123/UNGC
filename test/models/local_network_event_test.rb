require 'test_helper'

class LocalNetworkEventTest < ActiveSupport::TestCase
  should "trucate text that is too long" do
    FileTextExtractor.stubs(:extract).returns("a"*65530 + "b"*10000)
    ln = create(:local_network)
    create(:country, {
      local_network: ln
    })
    event = create_local_network_event({
      local_network: ln,
    })
    assert !!event.save
    assert_equal event.file_content.length, 65530
    assert_equal event.file_content[0], "a"
  end
end
