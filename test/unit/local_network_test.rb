require 'test_helper'

class LocalNetworkTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_have_many :countries
  should_have_many :contacts
  should_belong_to :manager
end
