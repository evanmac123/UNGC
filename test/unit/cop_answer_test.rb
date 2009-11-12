require 'test_helper'

class CopAnswerTest < ActiveSupport::TestCase
  should_belong_to :communication_on_progress
  should_belong_to :cop_attribute
end
