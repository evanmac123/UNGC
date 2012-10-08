require 'test_helper'

class CopLinkTest < ActiveSupport::TestCase
  should validate_presence_of :attachment_type
  # TODO test conditional validation
  # should validate_presence_of :language
  should belong_to :communication_on_progress
  should belong_to :language
  should allow_value :url, 'http://goodlink.com/'
  should_not allow_value :url, ['http://bad_link','no_protocol.com']
end
