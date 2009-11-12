require 'test_helper'

class CopLinkTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_belong_to :communication_on_progress
end
