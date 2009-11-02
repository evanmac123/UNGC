require 'test_helper'

class CopQuestionTest < ActiveSupport::TestCase
  should_validate_presence_of :principle_area_id, :text
  should_have_many :cop_attributes
  should_belong_to :principle_area
  should_belong_to :initiative
end
