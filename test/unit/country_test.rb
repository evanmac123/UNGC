require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  should_validate_presence_of :name, :code
end
