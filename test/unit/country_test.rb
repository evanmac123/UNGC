require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  should_validate_presence_of :name, :code
  should_have_and_belong_to_many :case_stories
end
