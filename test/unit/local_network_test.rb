require 'test_helper'

class LocalNetworkTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should have_many :countries
  should have_many :contacts
  should belong_to :manager
end
