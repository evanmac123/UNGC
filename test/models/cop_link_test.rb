require 'test_helper'

class CopLinkTest < ActiveSupport::TestCase
  should validate_presence_of :attachment_type
  should belong_to :communication_on_progress
  should belong_to :language
  should allow_value('http://goodlink.com/').for(:url)
  should_not allow_value(['http://bad_link','no_protocol.com']).for(:url)

  context "validate presence of language unless url is blank" do
    subject do
      CopLink.new(attachment_type: "cop", url: "http://goodlink.com/")
    end

    should validate_presence_of :language
  end
end
