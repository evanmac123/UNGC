require 'test_helper'

class CopFileTest < ActiveSupport::TestCase
  should_validate_presence_of :attachment_type
  should_belong_to :communication_on_progress
  should_belong_to :language
end
