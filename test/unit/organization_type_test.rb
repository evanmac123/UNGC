require 'test_helper'

class OrganizationTypeTest < ActiveSupport::TestCase
  should_validate_presence_of :name
end
