require 'test_helper'

class CopFileTest < ActiveSupport::TestCase
  should validate_presence_of :attachment_type
  should validate_presence_of :language
  should belong_to :communication_on_progress
  should belong_to :language
end
