require 'test_helper'

class ExchangeTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :code
  should belong_to :country
end
