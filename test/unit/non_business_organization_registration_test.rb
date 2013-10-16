require 'test_helper'

class NonBusinessOrganizationRegistrationTest < ActiveSupport::TestCase
  should belong_to :organization
end
