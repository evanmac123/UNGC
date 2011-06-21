require 'test_helper'

class CopLinkTest < ActiveSupport::TestCase
  should_validate_presence_of :attachment_type
  # TODO test conditional validation
  # should_validate_presence_of :language
  should_belong_to :communication_on_progress
  should_belong_to :language
  should_allow_values_for :url, 'http://goodlink.com/'
  should_not_allow_values_for :url, ['http://bad_link','no_protocol.com']
end