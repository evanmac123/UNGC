require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should have_and_belong_to_many :communication_on_progresses
end
