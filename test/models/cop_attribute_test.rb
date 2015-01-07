require 'test_helper'

class CopAttributeTest < ActiveSupport::TestCase
  should validate_presence_of :cop_question_id
  should belong_to :cop_question
end
