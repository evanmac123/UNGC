require 'test_helper'

class CopFileTest < ActiveSupport::TestCase
  should_validate_presence_of :name, :cop_id
  should_belong_to :communication_on_progress
end
