require 'test_helper'

class ExchangeTest < ActiveSupport::TestCase
  should_validate_presence_of :name, :code
  should_belong_to :country
end
