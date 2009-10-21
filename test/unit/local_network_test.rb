require 'test_helper'

class LocalNetworkTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_have_and_belong_to_many :countries
end
