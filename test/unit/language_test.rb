require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  should_validate_presence_of :namezz
  should_have_and_belong_to_many :communication_on_progresses
end
