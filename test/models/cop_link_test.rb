require 'test_helper'

class CopLinkTest < ActiveSupport::TestCase
  should validate_presence_of :attachment_type
  should belong_to :communication_on_progress
  should belong_to :language
  should allow_value('http://goodlink.com/').for(:url)
  should_not allow_value('no_protocol.com').for(:url)

  context "validate presence of language unless url is blank" do
    subject do
      CopLink.new(attachment_type: "cop", url: "http://goodlink.com/")
    end

    should validate_presence_of :language
  end

  test "should reject invalid large url" do
    cop_link = CopLink.new(attachment_type: "cop", url: "http://goodlink.com/B3lBn76KKzCmOvp7EVomvPSEsiwsE3Bo0H1WhhyZK6Xq5Co2wL0W2x8swBpqOvJ1xiUcUhBNnDuIceTTNyJa5Yj1q4qinFYBpg4VXbYiOeehI9G2V3oJjhiBWqS05YSHQyZBAKGcnO7njnL9A1vq5kBNB01yBSCIZ3Lb4uDMfZScmv7KMgrsGixzq46aL3IJQW8MH37loOlMU4NPVWAh0HMlMUDlDQsf48T9895kbtZ7z8JDYs8WUXsyNlrwcTv1")
    assert_not cop_link.valid?
  end
end
