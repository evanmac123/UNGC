require 'test_helper'

class CopAnswerTest < ActiveSupport::TestCase
  should belong_to :communication_on_progress
  should belong_to :cop_attribute
end
