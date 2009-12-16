require 'test_helper'

class CopLinkTest < ActiveSupport::TestCase
  should_validate_presence_of :attachment_type, :url
  should_belong_to :communication_on_progress
  should_belong_to :language
end
