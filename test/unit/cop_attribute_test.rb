require 'test_helper'

class CopAttributeTest < ActiveSupport::TestCase
  should_validate_presence_of :cop_question_id
  should_belong_to :cop_question
end
